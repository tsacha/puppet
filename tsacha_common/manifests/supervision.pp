class tsacha_common::supervision {

  $sensurqpass = hiera('rq::sensu_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'rsyslog':
    ensure => installed
  }

  service { 'rsyslog':
    ensure => running,
    require => Package['rsyslog']
  }

  file { "/etc/rsyslog.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_supervision/rsyslog/rsyslog.conf.erb'),
    require => Package['rsyslog'],
    notify => Service['rsyslog']
  }
  
  package { 'sensu':
    ensure => installed
  } ->

  file { "/etc/sensu/ssl":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => 0700,
    require => Package['sensu']
  } ->

  file { "/etc/sensu/ssl/cert.pem":
    owner => sensu,
    group => sensu,
    mode => 0600,
    source => "puppet:///modules/tsacha_private/autosign/sensu_cert.pem",
    require => File['/etc/sensu/ssl'],
    notify => Service['sensu-client']
  } ->

  file { "/etc/sensu/ssl/key.pem":
    owner => sensu,
    group => sensu,
    mode => 0400,
    source => "puppet:///modules/tsacha_private/autosign/sensu_key.pem",
    require => File['/etc/sensu/ssl'],
    notify => Service['sensu-client']
  } ->

  file { "/etc/sensu/conf.d/rabbitmq.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/rabbitmq.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-client']
  } ->

  file { "/etc/sensu/conf.d/client.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/client.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-client']
  } ->

  exec { "git-sensu-community-plugins":
    cwd => "/opt",
    command => "git clone git://github.com/sensu/sensu-community-plugins.git",
    unless => "stat /opt/sensu-community-plugins",
  }

  exec { "install-load-metrics":
    cwd => "/opt/",
    command => "cp sensu-community-plugins/plugins/system/load-metrics.rb /etc/sensu/plugins",
    require => [Package['sensu'],Exec['sensu-plugin']],
    notify => Service['sensu-client'],
    unless => "stat /etc/sensu/plugins/load-metrics.rb"
  }

  exec { "install-check-procs":
    cwd => "/opt/",
    command => "cp sensu-community-plugins/plugins/processes/check-procs.rb /etc/sensu/plugins",
    require => [Package['sensu'],Exec['sensu-plugin']],
    notify => Service['sensu-client'],
    unless => "stat /etc/sensu/plugins/check-procs.rb"
  }

  service { 'sensu-client':
    ensure => running,
    require => Exec['install-load-metrics']
  }

  exec { 'sensu-plugin':
    command => "gem install sensu-plugin --no-ri --no-rdoc",
    unless => "gem list | grep sensu-plugin"
  }

}