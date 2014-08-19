class tsacha_common::supervision {

  $sensurqpass = hiera('rq::sensu_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/opt/monitoring-plugins.tar.gz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0640,
    source => "puppet:///modules/tsacha_supervision/monitoring-plugins-2.0.tar.gz",
  } ->

  exec { "untar-plugins":
    command => "tar xvf monitoring-plugins.tar.gz",
    cwd => "/opt",
    unless => "stat monitoring-plugins-2.0"
  }

  if($operatingsystem == "Debian") {
    exec { "compile-plugins":
      command => "/opt/monitoring-plugins-2.0/configure --with-openssl && make && make install",
      cwd => "/opt/monitoring-plugins-2.0",
      timeout => 1000,
      require => [Exec['untar-plugins'],Package['build-essential'],Package['libssl-dev']],
      unless => "stat /usr/local/libexec/"
    }
  }

  if($operatingsystem == "CentOS") {
    exec { "compile-plugins":
      command => "/opt/monitoring-plugins-2.0/configure --with-openssl && make && make install",
      cwd => "/opt/monitoring-plugins-2.0",
      timeout => 1000,
      require => [Exec['untar-plugins'],Exec['development-tools'],Package['openssl-devel']],
      unless => "stat /usr/local/libexec/"
    }
  }

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

  file { "/var/run/sensu":
    ensure => directory,
    owner => sensu,
    group => root,
    mode => 0755,
    require => Package['sensu']
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

  service { 'sensu-client':
    ensure => running,
    require => File['/etc/sensu/conf.d/client.json']
  }

  exec { 'sensu-plugin':
    command => "gem install sensu-plugin --no-ri --no-rdoc",
    unless => "gem list | grep sensu-plugin"
  }

}