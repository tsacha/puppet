class tsacha_glenn::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  include tsacha_web::install

  package { 'php5-gd':
    ensure => installed
  }
  package { 'curl':
    ensure => installed
  }
  package { 'php5-curl':
    ensure => installed
  }

  package { 'ruby-dev':
    ensure => installed
  }

  package { 'libsqlite3-dev':
    ensure => installed
  }
  
  package { 'imagemagick':
    ensure => installed
  }
  
  package { 'sendmail':
    ensure => installed
  }
  
  file { "/etc/php5/apache2/php.ini":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_glenn/php.ini.erb'),
    notify => Service['apache2'],
    require => Package['libapache2-mod-php5'],
  }
}
