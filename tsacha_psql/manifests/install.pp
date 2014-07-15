class tsacha_psql::install {

  $psql_password = hiera('psql::pwd')
  $ip_address = hiera('network::ip_address')
  $cidr = hiera('network::cidr')
  $ip6_address = hiera('network::ip6_address')
  $cidr6 = hiera('network::cidr6')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'postgresql':
    ensure => installed
  }

  file { "/etc/postgresql/9.1/main/pg_hba.conf":
    owner   => postgres,
    group   => postgres,
    mode    => 640,
    ensure  => present,
    notify => Service['postgresql'],
    require => Package['postgresql'],
    content => template('tsacha_psql/pg_hba.conf.erb'),
  }


  file { "/etc/postgresql/9.1/main/postgresql.conf":
    owner   => postgres,
    group   => postgres,
    mode    => 644,
    ensure  => present,
    notify => Service['postgresql'],
    require => Package['postgresql'],
    content => template('tsacha_psql/postgresql.conf.erb'),
  }

  exec { "change-password":
     command => "psql -U postgres -d postgres -c \"alter user postgres with password '$psql_password';\"",
     onlyif => "psql -U postgres -d postgres -c \"select passwd from pg_catalog.pg_shadow where usename='postgres' and passwd IS NOT NULL\" | grep rows",
     user => postgres
  }
  
  service { 'postgresql':
    ensure => running
  }

}