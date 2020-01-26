class mymodule::subclass2 {
   file { "/var/ftp/pub":
ensure => 'directory',
 mode => '0644'
}
}
