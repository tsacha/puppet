class tsacha_supervision::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  apt::source { 'icinga':
    location          => 'http://packages.icinga.org/debian',
    release           => 'icinga-unstable',
    repos             => 'main',
    include_src       => true,
    notify	      => Exec['repo_changed_update']
  } ->

  apt::key { 'icinga':
    key        => '34410682',
    key_source => 'http://packages.icinga.org/icinga.key',
    notify     => Exec['repo_changed_update']
  } ->

  package { 'icinga2':
    ensure => installed
  } ->

  service { 'icinga2':
    ensure => running
  }

  package { 'icinga2-classicui':
    ensure => installed
  }

  package { 'php5':
    ensure => installed
  }

  package { 'php5-fpm':
    ensure => installed
  }

  package { 'php-apc':
    ensure => installed
  }

  package { 'fcgiwrap':
    ensure => installed
  }

  file { "/etc/icinga2/classicui/htpasswd.users":
    ensure => present,
    owner => root,
    group => www-data,
    mode => 640,
    source => "puppet:///modules/tsacha_supervision/htpasswd.users",
    require => Package['icinga2-classicui']
  }

  file { "/etc/icinga2/classicui/cgi.cfg":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_supervision/cgi.cfg.erb'),
    require => Package['icinga2-classicui'],
    notify => Service['icinga2']
  }

  file { "/etc/icinga2/conf.d/users.conf":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_supervision/users.conf.erb'),
    require => Package['icinga2'],
    notify => Service['icinga2']
  }

  file { "/usr/share/icinga2/include/command-plugins.conf":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_supervision/command-plugins.conf.erb'),
    require => Package['icinga2'],
    notify => Service['icinga2']
  }  

}