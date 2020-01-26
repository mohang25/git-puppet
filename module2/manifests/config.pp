class mymodule2::config {
file { "/var/www/html/index.html":
ensure => 'file',
#content => "web server deployed using puppet module-Mohan.",
content => template('mymodule2/myhomepage.erb'),
mode => '0644',
require => package["httpd"]
}
}
