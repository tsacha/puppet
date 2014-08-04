class tsacha_supervision::elk {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'elasticsearch':
    ensure => installed
  }

  service { 'elasticsearch':
    ensure => running,
    require => Package['elasticsearch']
  } 

  file { "/opt/kibana.tgz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/kibana-3.1.0.tar.gz",
  } ~>

  exec { "extract-kibana":
    command => "tar xvf kibana.tgz",
    cwd => "/opt",
    require => File['/opt/kibana.tgz'],
    refreshonly => true
  }

  file { "/opt/kibana-3.1.0/config.js":
    ensure => present,
    owner => root,
    group => root,
    mode => 0664,
    content => template('tsacha_supervision/kibana.js.erb'),
    require => Exec['extract-kibana']
  }

  package { 'openjdk-7-jre-headless':
    ensure => installed
  }

  file { "/opt/logstash.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    require => Package['openjdk-7-jre-headless'],
    source => "puppet:///modules/tsacha_supervision/logstash_1.4.2-1-2c0f5a1_all.deb",
  } ~>

  package { 'logstash':
    provider => dpkg,
    ensure => installed,
    source => "/opt/logstash.deb",
    require => File['/opt/logstash.deb']
  }

  service { 'logstash':
    ensure => running,
    require => Package['logstash']
  }

  file { "/etc/logstash/conf.d/logstash.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_supervision/logstash.conf.erb'),
    require => Package['logstash'],
    notify => Service['logstash']
  }

}