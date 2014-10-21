class tsacha_psql::install {

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

  $psql_password = hiera('psql::pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'postgresql-server':
    ensure => installed
  }

  package { 'postgresql':
    ensure => installed
  }

  exec { 'initdb':
    command => "initdb /var/lib/pgsql/data",
    user => "postgres",
    unless => "stat /var/lib/pgsql/data/postgresql.conf",
    require => Package['postgresql']
  }

  file { "/var/lib/pgsql/data/pg_hba.conf":
    owner   => postgres,
    group   => postgres,
    mode    => '0640',
    ensure  => present,
    notify => Service['postgresql'],
    require => Exec['initdb'],
    content => template('tsacha_psql/pg_hba.conf.erb'),
  }


  file { "/var/lib/pgsql/data/postgresql.conf":
    owner   => postgres,
    group   => postgres,
    mode    => '0644',
    ensure  => present,
    notify => Service['postgresql'],
    require => Exec['initdb'],
    content => template('tsacha_psql/postgresql.conf.erb'),
  }

  exec { "change-password":
     command => "psql -U postgres -d postgres -c \"alter user postgres with password '$psql_password';\"",
     onlyif => "psql -U postgres -d postgres -c \"select passwd from pg_catalog.pg_shadow where usename='postgres' and passwd IS NOT NULL\" | grep rows",
     user => postgres,
     require => [Package['postgresql'],Package['postgresql-server']],
  }
  
  service { 'postgresql':
    ensure => running
  } ->

  exec { 'enable-postgresql':
    command => "systemctl enable postgresql",
    unless => "systemctl is-enabled postgresql",
  }    

}
