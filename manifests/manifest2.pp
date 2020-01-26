file {"/root/myfile123.txt":
ensure => 'file',
owner => 'root',
group => 'wheel',
content => 'This is my manifest file deployed using puppet\n'
}
