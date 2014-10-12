class tsacha_dns::install {

  $hosts = hiera_hash('hosts')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'bind':
    ensure => installed,
    notify => Service['named']
  } ->
  
  package { 'bind-utils':
    ensure => installed
  }

  file { "/etc/named.conf":
    owner => root,
    group => named,
    mode => '0640',
    ensure => present,
    content => template('tsacha_dns/named.conf.erb'),
    require => Package['bind']
  }

  file { "/etc/named.conf.local":
    owner => root,
    group => named,
    mode => '0640',
    ensure => present,
    content => template('tsacha_dns/named.conf.local.erb'),
    require => Package['bind']
  }

}
