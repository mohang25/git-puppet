class mymodule2::service {
service { "httpd":
ensure => 'running',
enable => 'true',
require => File["/var/www/html/index.html"]
   } 
}
