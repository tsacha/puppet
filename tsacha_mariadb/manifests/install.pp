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
  $subnet6 = hiera('mariadb::subnet6')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'mariadb-server':
    ensure => installed
  }

  package { 'mariadb':
    ensure => installed
  }

  file { "/etc/my.cnf":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    content => template('tsacha_mariadb/my.cnf.erb'),
    require => Package['mariadb-server'],
    notify => Service['mariadb']
  }

  exec { "pass-db":
    command => "mysqladmin -u root password $mariadb_password",
    unless => "mysqladmin status -p'$mariadb_password'",
    require => [Package['mariadb'],Service['mariadb']]
  }
  
  exec { "pass-mysql-user":
    command => "mysql -p'$mariadb_password' -u root -e 'UPDATE mysql.user SET Password=PASSWORD(\"$mariadb_password\") WHERE user=\"root\"'",
    unless => "test -z $(mysql -N --batch --password='$mariadb_password' -e 'select password from mysql.user where user=\"root\" and host=\"127.0.0.1\" and password is null limit 1;')",
    require => Exec['pass-db']
  }

  exec { "remove-test-db":
    command => "mysql -p'$mariadb_password' -u root -e 'DELETE FROM mysql.db WHERE Db=\"test\" OR Db=\"test\_%\"'",
    unless => "test -z $(mysql -N --batch --password='$mariadb_password' -e 'select db from mysql.db where db=\"test\" limit 1;')",
    require => Exec['pass-db']
  }

  exec { "grant-subnet4":
    command => "mysql -p'$mariadb_password' -e \"GRANT ALL ON *.* to root@'10.%' IDENTIFIED BY '$mariadb_password' WITH GRANT OPTION\";",
    unless => "mysql -p'$mariadb_password' -e \"SHOW GRANTS for root@'10.%'\";"
  }  

  $subnet6.each |$v| {
    exec { "grant-subnet6-$v":
    command => "mysql -p'$mariadb_password' -e \"GRANT ALL ON *.* to root@'$v' IDENTIFIED BY '$mariadb_password' WITH GRANT OPTION\";",
    unless => "mysql -p'$mariadb_password' -e \"SHOW GRANTS for root@'$v'\";"  
    }
  }

  service { 'mariadb':
    ensure => running,
    require => [Package['mariadb-server'],File['/etc/my.cnf']]
  }

}
