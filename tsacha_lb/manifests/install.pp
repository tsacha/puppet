class tsacha_lb::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'nginx':
    ensure => installed
  }  

  service { 'apache2':
  }

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure => absent,
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => absent,
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    notify => Service['apache2']
  }

  file { "/etc/apache2/ports.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0640,
    notify => Service['apache2'],
    content => template('tsacha_lb/ports.conf.erb'),
  }

  file { "/etc/nginx/sites-available/default":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    require => Package['nginx'],
    content => template('tsacha_lb/nginx.erb'),
  }

  file { "/etc/nginx/sites-enabled/default":
    ensure => present,
    target => "/etc/nginx/sites-available/default",
    notify => Service['nginx'],
  }

}