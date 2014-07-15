class tsacha_web::install {

  $psql_password = hiera('psql::pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'apache2':
    ensure => installed
  }

  package { 'postgresql-client':
    ensure => installed
  }

  file { '/srv/web':
    ensure => directory,
    owner => www-data, 
    group => www-data,
    mode => 775
  }

  file { '/etc/apache2/sites-available/000-default.conf':
    ensure => absent,
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-available/default-ssl.conf':
    ensure => absent,
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { '/etc/apache2/sites-enabled/000-default.conf':
    ensure => absent,
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/ssl.load":
    ensure => link,
    target => "/etc/apache2/mods-available/ssl.load",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/ssl.conf":
    ensure => link,
    target => "/etc/apache2/mods-available/ssl.conf",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/proxy.load":
    ensure => link,
    target => "/etc/apache2/mods-available/proxy.load",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/proxy_http.load":
    ensure => link,
    target => "/etc/apache2/mods-available/proxy_http.load",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/rewrite.load":
    ensure => link,
    target => "/etc/apache2/mods-available/rewrite.load",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/mods-enabled/socache_shmcb.load":
    ensure => link,
    target => "/etc/apache2/mods-available/socache_shmcb.load",
    require => Package['apache2'],
    notify => Service['apache2']
  }

  file { "/etc/apache2/apache2.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    require => Package['apache2'],
    notify => Service['apache2'],
    content => template('tsacha_web/apache2.conf.erb'),
  }

  file { "/etc/apache2/ports.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    require => Package['apache2'],
    notify => Service['apache2'],
    content => template('tsacha_web/ports.conf.erb'),
  }

  package { ['php5-common','libapache2-mod-php5','php5-cli','php5-intl','php5-mcrypt','php5-pgsql']:
    ensure => installed,
    notify => Service['apache2'],
    require => Package['apache2']
  } ->

  exec { "set-timezone":
    command => "sed -i 's/;date.timezone =/date.timezone = UTC/g' /etc/php5/apache2/php.ini",
    unless => "grep UTC /etc/php5/apache2/php.ini",
    notify => Service['apache2']
  }
}