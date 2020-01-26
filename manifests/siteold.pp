#node default {
#file { "/root/hostbase2_deploy":
#ensure =>'file',
#content =>"deployed using site.pp"
#}
#}
#node 'ip-172-31-5-224.ap-south-1.compute.internal' {
#file {"/root/ad-hocfile":
#ensure => 'file',
#owner => 'root'
#}
#}

####Declaring the varilables.
node 'ip-172-31-5-224.ap-south-1.compute.internal' {
$user=myuser1
$file="/root/myfile"
user { 'user2':
ensure => 'present',
managehome => 'true'
}
file {'/root/document':
ensure => 'file',
owner => 'root'
}
}

