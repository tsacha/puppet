class tsacha_tc::install {

  $hosts = hiera_hash('hosts')
  $domain_split = split($domain, '[.]')
  $hypervisor = $domain_split[0]  

  $mariadb_password = hiera('mariadb::pwd')
  $tc_password = hiera('tc::pwd')
  $ip6_address = $hosts[$hypervisor][$hostname]['ip6']
  $cidr6 = $hosts[$hypervisor]['physical']['cidr6']

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'httpd':
    ensure => installed
  }

  package { 'php':
    ensure => installed
  }

  package { 'php-mysql':
    ensure => installed
  }

  package { 'mariadb':
    ensure => installed
  }

  file { '/srv/web':
    ensure => directory,
    owner => apache, 
    group => apache,
    mode => '0775',
    require => Package['httpd']
  }

  file { '/etc/httpd/conf.d/tc.conf':
    ensure => file,
    owner => apache, 
    group => apache,
    mode => '0644',
    require => Package['httpd'],
    notify => Service['httpd'],
    content => template('tsacha_tc/tc.conf.erb')
  }

  file { '/etc/httpd/conf.d/welcome.conf':
    ensure => absent,
    require => Package['httpd'],
    notify => Service['httpd']
  }

  exec { "grant-subnet6":
    command => "mysql -h mariadb.trs.io -p'$mariadb_password' -e \"GRANT ALL ON *.* to tc@'$hostname' IDENTIFIED BY '$tc_password' WITH GRANT OPTION\";",
    unless => "mysql -h mariadb.trs.io -p'$mariadb_password' -e \"SHOW GRANTS for tc@'$hostname'\";",
    require => Package['mariadb']
  }    

}
