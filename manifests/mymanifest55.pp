if $::osfamily == "Redhat"{
user {"ec2-user":
ensure => 'present',
managehome => 'true'
}
}
else {
user { "someother_user":
ensure => 'true'
}
}
