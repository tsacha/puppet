class tsacha_glenn::prestashop {

  $psql_password = hiera('psql::pwd')
  $prestashop_password = hiera('glenn::prestashop_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

  file { "/etc/apache2/sites-available/prestashop.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => File['/etc/apache2/sites-enabled/prestashop.conf'],
    content => template('tsacha_glenn/prestashop.erb'),
  }


  file { "/srv/web/prestashop":
    ensure => directory,
    owner => www-data,
    group => www-data,
    mode => '0775'
  }

  file { "/etc/apache2/sites-enabled/prestashop.conf":
    ensure => link,
    target => "/etc/apache2/sites-available/prestashop.conf",
    notify => Service['apache2']
  }

  package { 'mariadb-client':
    ensure => installed
  }

  exec { "create-prestashop-db":
    command => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"create database prestashop\";",
    unless => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"show databases\" | grep prestashop",
  } ->

  exec { "create-prestashop-userdb":
    command => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"grant usage on *.* to prestashop@'10.2.0.101' identified by '$prestashop_password'\";",
    unless => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"show grants for prestashop@'10.2.0.101'\" | grep USAGE"
  } ->

  exec { "grant-prestashop-userdb":
    command => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"grant all privileges on prestashop.* to prestashop@'10.2.0.101' identified by '$prestashop_password'\";",
    unless => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"show grants for prestashop@'10.2.0.101'\" | grep PRIVILEGES"
  }

  exec { "create-prestashop-userdb6":
    command => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"grant usage on *.* to prestashop@'2001:41d0:2:9566:1::101' identified by '$prestashop_password'\";",
    unless => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"show grants for prestashop@'2001:41d0:2:9566:1::101'\" | grep USAGE"
  } ->

  exec { "grant-prestashop-userdb6":
    command => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"grant all privileges on prestashop.* to prestashop@'2001:41d0:2:9566:1::101' identified by '$prestashop_password'\";",
    unless => "mysql -h mariadb.duna.trs.io -p$psql_password -e \"show grants for prestashop@'2001:41d0:2:9566:1::101'\" | grep PRIVILEGES"
  }


}