class mymodule::subclass3 {
service {"vsftpd":
ensure => 'running',
enable => 'true'
}
}
