package {"httpd":
ensure => 'present',
}
#to configure the home page
file {"/var/www/html/index.html":
ensure => 'file',
content => "web server home page. Configured using the puppet server",
mode => '0644'
}
##restarting the server
service {"httpd":
ensure => 'running',
enable => 'true'
} 

