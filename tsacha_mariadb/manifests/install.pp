class tsacha_mariadb::install {

  $hosts = hiera_hash('hosts')
  $domain_split = split($domain, '[.]')
  $hypervisor = $domain_split[0]

  $ip_sup_address = $hosts['kerbin']['physical']['ip_private_address']
  $cidr_sup = $hosts['kerbin']['physical']['cidr_private']
  $ip6_sup_address = $hosts['kerbin']['physical']['ip6']
  $cidr6_sup = $hosts['kerbin']['physical']['cidr6']

  $ip_address = $hosts[$hypervisor][$hostname]['ip']
  $cidr = $hosts[$hypervisor]['physical']['cidr_private']
  $gateway = $hosts[$hypervisor]['physical']['ip_private_address']
  $ip6_address = $hosts[$hypervisor][$hostname]['ip6']
  $cidr6 = $hosts[$hypervisor]['physical']['cidr6']
  $gateway6 = $hosts[$hypervisor]['physical']['gateway6']

  $mariadb_password = hiera('mariadb::pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'mariadb-server':
    ensure => installed
  }

  file { "/etc/mysql/my.cnf":
    owner   => root,
    group   => root,
    mode    => 0644,
    ensure  => present,
    notify => Service['mysql'],
    require => Package['mariadb-server'],
    content => template('tsacha_mariadb/my.cnf.erb'),
  }

  exec { "grant-subnet4":
    command => "mysql -e \"GRANT ALL ON *.* to root@'10.%' IDENTIFIED BY '$mariadb_password' WITH GRANT OPTION\";",
    unless => "mysql -e \"SHOW GRANTS for root@'10.%'\";"
  }  

  exec { "grant-subnet6":
    command => "mysql -e \"GRANT ALL ON *.* to root@'2001:41d0:2:9566:1::%' IDENTIFIED BY '$mariadb_password' WITH GRANT OPTION\";",
    unless => "mysql -e \"SHOW GRANTS for root@'2001:41d0:2:9566:1::%'\";"  
  }

  service { 'mysql':
    ensure => running,
    require => Package['mariadb-server']
  }

}