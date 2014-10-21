class tsacha_supervision::sensu {

  Exec { path => [ "/opt/rabbitmq/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  $sensu_passwd = hiera('rq::sensu')

  group { "sensu":
    ensure => present
  }
  
  user { "sensu":
    ensure => present,
    gid => "sensu",
    home => "/",
    shell => "/bin/false",
    require => Group["sensu"]
  }

  exec { 'gem-sensu':
    command => "gem install sensu",
    unless => "gem list -i ^sensu$",
    timeout => 2000,
    require => [User['sensu'],Package['ruby-devel']]
  }

  exec { 'gem-sensu-plugin':
    command => "gem install sensu-plugin",
    unless => "gem list -i ^sensu-plugin$",
    require => Exec['gem-sensu'],
    timeout => 2000
  }

  file { "/etc/sensu/":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => Exec['gem-sensu']
  }      

  file { "/etc/sensu/ssl":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => File['/etc/sensu/']
  }

  file { "/etc/sensu/conf.d":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => File['/etc/sensu/']
  }

  file { "/etc/sensu/extensions":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => File['/etc/sensu']
  }  

  file { "/var/log/sensu":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => Exec['gem-sensu']
  }  

  file { "/etc/sensu/ssl/cert.pem":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/sensu_cert.pem",
    require => File['/etc/sensu/ssl']
  }

  file { "/etc/sensu/ssl/key.pem":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/sensu_key.pem",
    require => File['/etc/sensu/ssl']
  }

  file { "/etc/sensu/ssl/cacert.pem":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/tsacha_ca/cacert.pem",
    require => File['/etc/sensu/ssl']
  }

  file { "/etc/sensu/extensions/handlers":
    ensure => directory,
    owner => sensu,
    group => sensu,
    mode => "0755",
    require => File['/etc/sensu/extensions']
  }    

  file { "/etc/sensu/extensions/handlers/flapjack.rb":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0644",
    source => "puppet:///modules/tsacha_supervision/flapjack.rb",
    require => File['/etc/sensu/extensions/handlers'],
  }  

  file { "/etc/sensu/config.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0644",
    content => template('tsacha_supervision/sensu.config.js.erb'),
    require => File['/etc/sensu'],
    notify => Service['sensu-client']
  }


  file { "/etc/sensu/conf.d/client.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0644",
    content => template('tsacha_supervision/client.sensu.config.js.erb'),
    require => File['/etc/sensu/conf.d'],
    notify => Service['sensu-client']
  }

  file { "/etc/sensu/conf.d/flapjack.json":
    ensure => present,
    owner => sensu,
    group => sensu,
    mode => "0644",
    content => template('tsacha_supervision/flapjack.sensu.config.js.erb'),
    require => File["/etc/sensu/extensions/handlers/flapjack.rb"]
  }

  file { "/etc/systemd/system/sensu-api.service":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    source => "puppet:///modules/tsacha_supervision/sensu-api.service",
    notify => Exec["refresh-units"],
    require => Exec['gem-sensu']
  }

  file { "/etc/systemd/system/sensu-server.service":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    source => "puppet:///modules/tsacha_supervision/sensu-server.service",
    notify => Exec["refresh-units"],
    require => Exec['gem-sensu']    
  }

  file { "/etc/systemd/system/sensu-client.service":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    source => "puppet:///modules/tsacha_supervision/sensu-client.service",
    notify => Exec["refresh-units"],
    require => Exec['gem-sensu']    
  }  

  exec { 'enable-sensu-client':
    command => "systemctl enable sensu-client",
    unless => "systemctl is-enabled sensu-client",
    require => File["/etc/systemd/system/sensu-client.service"]
  } ->    

  service { 'sensu-client':
    ensure => running,
    require => [File['/etc/sensu/conf.d/client.json'],File['/etc/sensu/config.json'],File['/var/log/sensu']]
  }  

}
