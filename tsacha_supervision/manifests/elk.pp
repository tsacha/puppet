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

  package { 'graphite-carbon':
    ensure => installed
  }

  file { "/etc/default/graphite-carbon":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_supervision/graphite-carbon.erb'),
    require => Package['graphite-carbon'],
    notify => Service['carbon-cache']
  }

  service { 'carbon-cache':
    ensure => running,
    require => File['/etc/default/graphite-carbon']
  }

  package { ['graphite-web','apache2','apache2-mpm-worker','libapache2-mod-wsgi', 'python-twisted','python-memcache','python-pysqlite2','python-simplejson']:
    ensure => installed,
    notify => Exec['db-graphite']
  } ->

  file { '/etc/apache2/sites-enabled/graphite.conf':
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_supervision/graphite.apache.erb'),
    notify => Service['apache2']
  }

  exec { 'db-graphite':
    cwd => "/var/lib/graphite",
    command => "sudo -u _graphite graphite-manage syncdb --noinput",
    refreshonly => true
  }

  file { "/opt/grafana.tgz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/grafana-1.7.0-rc1.tar.gz",
  } ~>

  exec { "extract-grafana":
    command => "tar xvf grafana.tgz",
    cwd => "/opt",
    require => File['/opt/grafana.tgz'],
    refreshonly => true
  }

  file { '/opt/grafana-1.7.0-rc1/config.js':
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    require => Exec['extract-grafana'],
    notify => Service['apache2'],
    content => template('tsacha_supervision/config.js.grafana.erb'),
  }

}