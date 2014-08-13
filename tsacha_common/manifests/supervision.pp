class tsacha_common::supervision {

  $sensurqpass = hiera('rq::sensu_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  group { "naemon":
    ensure => present
  } ->

  user { "naemon":
    ensure => present,
    shell => "/bin/bash",
    home => "/var/lib/naemon"
  }
    
  file { "/var/lib/naemon":
    ensure => directory,
    owner => naemon,
    group => naemon,
    mode => 0755,
    require => [User['naemon'],Group['naemon']]
  }

  file { "/var/lib/naemon/.ssh":
    ensure => directory,
    owner => naemon,
    group => naemon,
    mode => 0750,
    require => File['/var/lib/naemon']
  }

  file { "/opt/monitoring-plugins.tar.gz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0640,
    source => "puppet:///modules/tsacha_supervision/nagios-plugins-1.5.tar.gz",
  } ->

  exec { "untar-plugins":
    command => "tar xvf monitoring-plugins.tar.gz",
    cwd => "/opt",
    unless => "stat nagios-plugins-1.5"
  } ->
  
  exec { "compile-plugins":
    command => "/opt/nagios-plugins-1.5/configure --with-openssl && make && make install",
    cwd => "/opt/nagios-plugins-1.5",
    timeout => 1000,
    require => [Package['build-essential'],Package['libssl-dev']],
    unless => "stat /usr/local/nagios/libexec/"
  }


  file { "/usr/local/nagios/libexec/check_puppet_agent.rb":
    ensure => present,
    owner => root,
    group => staff,
    mode => 0755,
    source => "puppet:///modules/tsacha_supervision/check_puppet_agent.rb",
    require => Exec['compile-plugins']
  }

  file { "/usr/local/nagios/libexec/check_ldap":
    ensure => present,
    owner => root,
    group => staff,
    mode => 0755,
    source => "puppet:///modules/tsacha_supervision/check_ldap",
    require => Exec['compile-plugins']
  }

  file { "/usr/local/nagios/libexec/check_postgres":
    ensure => present,
    owner => root,
    group => staff,
    mode => 0755,
    source => "puppet:///modules/tsacha_supervision/check_postgres.pl",
    require => Exec['compile-plugins']
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
    content => template('tsacha_supervision/rsyslog.conf.erb'),
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
    content => template('tsacha_supervision/sensu.rabbitmq.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-client']
  } ->

  file { "/etc/sensu/conf.d/client.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => 0664,
    content => template('tsacha_supervision/sensu.client.json.erb'),
    require => Package['sensu'],
    notify => Service['sensu-client']
  } ->

  exec { "git-sensu-community-plugins":
    cwd => "/opt",
    command => "git clone git://github.com/sensu/sensu-community-plugins.git",
    unless => "stat /opt/sensu-community-plugins",
  } ~>

  exec { "install-sensu-community-plugins":
    cwd => "/opt/",
    command => "cp sensu-community-plugins/plugins/system/load-metrics.rb /etc/sensu/plugins",
    require => [Package['sensu'],Exec['sensu-plugin']],
    notify => Service['sensu-client'],
    refreshonly => true
  }

  service { 'sensu-client':
    ensure => running,
    require => Exec['install-sensu-community-plugins']
  }

  exec { 'sensu-plugin':
    command => "gem install sensu-plugin --no-ri --no-rdoc",
    unless => "gem list | grep sensu-plugin"
  }

}