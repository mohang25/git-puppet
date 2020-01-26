require 'net/https'
require 'openssl'

require 'puppetserver/ca/errors'

module Puppetserver
  module Ca
    module Utils
      # Utilities for doing HTTPS against the CA that wraps Net::HTTP constructs
      class HttpClient

        DEFAULT_HEADERS = {
          'User-Agent'   => 'PuppetserverCaCli',
          'Content-Type' => 'application/json',
          'Accept'       => 'application/json'
        }

        attr_reader :store

        # Not all connections require a client cert to be present.
        # For example, when querying the status endpoint.
        def initialize(settings, with_client_cert: true)
          @store = make_store(settings[:localcacert],
                              settings[:certificate_revocation],
                              settings[:hostcrl])

          if with_client_cert
            @cert = load_cert(settings[:hostcert])
            @key = load_key(settings[:hostprivkey])
          else
            @cert = nil
            @key = nil
          end
        end

        def load_cert(path)
          load_with_errors(path, 'hostcert') do |content|
            OpenSSL::X509::Certificate.new(content)
          end
        end

        def load_key(path)
          load_with_errors(path, 'hostprivkey') do |content|
            OpenSSL::PKey.read(content)
          end
        end

        # Takes an instance URL (defined lower in the file), and creates a
        # connection. The given block is passed our own Connection object.
        # The Connection object should have HTTP verbs defined on it that take
        # a body (and optional overrides). Returns whatever the block given returned.
        def with_connection(url, &block)
          request = ->(conn) { block.call(Connection.new(conn, url)) }

          begin
            Net::HTTP.start(url.host, url.port,
                            use_ssl: true, cert_store: @store,
                            cert: @cert, key: @key,
                            &request)
          rescue StandardError => e
            raise ConnectionFailed.create(e,
                    "Failed connecting to #{url.full_url}\n" +
                    "  Root cause: #{e.message}")
          end
        end

        private

       def load_with_errors(path, setting, &block)
          begin
            content = File.read(path)
            block.call(content)
          rescue Errno::ENOENT => e
            raise FileNotFound.create(e,
                    "Could not find '#{setting}' at '#{path}'")

          rescue OpenSSL::OpenSSLError => e
            raise InvalidX509Object.create(e,
                    "Could not parse '#{setting}' at '#{path}'.\n" +
                    "  OpenSSL returned: #{e.message}")
          end
       end

        # Helper class that wraps a Net::HTTP connection, a HttpClient::URL
        # and defines methods named after HTTP verbs that are called on the
        # saved connection, returning a Result.
        class Connection
          def initialize(net_http_connection, url_struct)
            @conn = net_http_connection
            @url = url_struct
          end

          def get(url_overide = nil, headers = {})
            url = url_overide || @url
            headers = DEFAULT_HEADERS.merge(headers)

            request = Net::HTTP::Get.new(url.to_uri, headers)
            result = @conn.request(request)

            Result.new(result.code, result.body)
          end

          def put(body, url_override = nil, headers = {})
            url = url_override || @url
            headers = DEFAULT_HEADERS.merge(headers)

            request = Net::HTTP::Put.new(url.to_uri, headers)
            request.body = body
            result = @conn.request(request)

            Result.new(result.code, result.body)
          end

          def delete(url_override = nil, headers = {})
            url = url_override || @url
            headers = DEFAULT_HEADERS.merge(headers)

            result = @conn.request(Net::HTTP::Delete.new(url.to_uri, headers))

            Result.new(result.code, result.body)
          end
        end

        # Just provide the bits of Net::HTTPResponse we care about
        Result = Struct.new(:code, :body)

        # Like URI, but not... maybe of suspicious value
        URL = Struct.new(:protocol, :host, :port,
                         :endpoint, :version,
                         :resource_type, :resource_name) do
                def full_url
                  protocol + '://' + host + ':' + port + '/' +
                  [endpoint, version, resource_type, resource_name].join('/')
                end

                def to_uri
                  URI(full_url)
                end
              end

        def make_store(bundle, crl_usage, crls = nil)
          store = OpenSSL::X509::Store.new
          store.purpose = OpenSSL::X509::PURPOSE_ANY
          store.add_file(bundle)

          if crl_usage != :ignore

            flags = OpenSSL::X509::V_FLAG_CRL_CHECK
            if crl_usage == :chain
              flags |= OpenSSL::X509::V_FLAG_CRL_CHECK_ALL
            end

            store.flags = flags
            delimiter = /-----BEGIN X509 CRL-----.*?-----END X509 CRL-----/m
            File.read(crls).scan(delimiter).each do |crl|
              store.add_crl(OpenSSL::X509::CRL.new(crl))
            end
          end

          store
        end
      end
    end
  end
end
