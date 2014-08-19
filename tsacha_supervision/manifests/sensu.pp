class tsacha_supervision::sensu {

  $sensurqpass = hiera('rq::sensu_pwd')
  $sensuapipass = hiera('rq::sensu_api')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'uchiwa':
    ensure => installed
  }

  exec { "sensu-vhost":
    command => "rabbitmqctl add_vhost /sensu",
    unless => "rabbitmqctl list_vhosts | grep sensu",
  } ->

  exec { "sensu-rq-user":
    command => "rabbitmqctl add_user sensu $sensurqpass",
    unless => "rabbitmqctl list_users | grep sensu"
  } ->

  exec { "sensu-rq-perm":
    command => 'rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"',
    unless => "rabbitmqctl list_user_permissions sensu | grep /sensu"
  }

  file { "/etc/sensu/conf.d/redis.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/redis.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-server']
  }

  file { "/etc/sensu/conf.d/api.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/api.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-api']
  }

  file { "/etc/sensu/uchiwa.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/uchiwa.json.erb'),
    require => Package['sensu'],
    notify => Service['uchiwa']
  }

  file { "/etc/sensu/conf.d/relay.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/relay.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-server']
  }

  file { "/etc/sensu/conf.d/checks.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/checks.json.erb'),
    require => Package['sensu'],
    notify => [Service['sensu-server'],Service['sensu-api']],
  }

  file { "/etc/sensu/conf.d/flapjack.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu/flapjack.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-server'],
  }

  exec { "git-sensu-metrics-relay":
    cwd => "/opt",
    command => "git clone git://github.com/opower/sensu-metrics-relay.git",
    unless => "stat /opt/sensu-metrics-relay",
  } ~>

  exec { "install-sensu-metrics-relay":
    cwd => "/opt/sensu-metrics-relay",
    command => "cp -R lib/sensu/extensions/* /etc/sensu/extensions",
    require => Package['sensu'],
    notify => Service['sensu-server'],
    refreshonly => true
  }

  exec { "install-sensu-to-flapjack":
    cwd => "/opt/",
    command => "cp sensu-community-plugins/extensions/handlers/flapjack.rb /etc/sensu/extensions/handlers/",
    require => [Package['sensu'],Exec['sensu-plugin'],File["/etc/sensu/conf.d/flapjack.json"]],
    notify => Service['sensu-server'],
    unless => "stat /etc/sensu/extensions/handlers/flapjack.rb"
  }

  service { 'sensu-server':
    ensure => running,
    require => [File['/etc/sensu/ssl/key.pem'],File['/etc/sensu/ssl/key.pem'],File['/etc/sensu/conf.d/rabbitmq.json'],File['/etc/sensu/conf.d/redis.json'],File['/etc/sensu/conf.d/relay.json'],Exec["install-sensu-to-flapjack"]]
  }

  service { 'sensu-api':
    ensure => running,
    require => [File['/etc/sensu/ssl/key.pem'],File['/etc/sensu/ssl/key.pem'],File['/etc/sensu/conf.d/rabbitmq.json'],File['/etc/sensu/conf.d/redis.json'],File['/etc/sensu/conf.d/api.json']]
  }

  service { 'uchiwa':
    ensure => running,
    require => [Service['sensu-server'],Service['sensu-api']]
  }

}