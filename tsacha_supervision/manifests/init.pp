class tsacha_supervision {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  class { 'tsacha_supervision::install': } ->
  class { 'tsacha_supervision::rabbitmq': } ->
  class { 'tsacha_supervision::redis': } ->
  
  service { 'redis':
    ensure => running,
  } ->

  exec { 'enable-redis':
    command => "systemctl enable redis",
    unless => "systemctl is-enabled redis",
  } ->

  service { 'rabbitmq-server':
     ensure => running,
  } ->

  exec { 'enable-rabbitmq-server':
    command => "systemctl enable rabbitmq-server",
    unless => "systemctl is-enabled rabbitmq-server",
  } ->

  class { 'tsacha_supervision::rabbitmqconfig': } ->

  exec { 'enable-sensu-server':
    command => "systemctl enable sensu-server",
    unless => "systemctl is-enabled sensu-server"
  } ->

  service { 'sensu-server':
    ensure => running,
    subscribe => [File['/etc/sensu/config.json'],File['/etc/sensu/conf.d/flapjack.json'],File['/var/log/sensu']]    
  } ->

  exec { 'enable-sensu-api':
    command => "systemctl enable sensu-api",
    unless => "systemctl is-enabled sensu-api"
  } ->    

  service { 'sensu-api':
    ensure => running,
    subscribe => [File['/etc/sensu/config.json'],File['/etc/sensu/conf.d/flapjack.json'],File['/var/log/sensu']]
  } ->    
  
  class { 'tsacha_supervision::uchiwa': } ->


  exec { 'enable-uchiwa':
    command => "systemctl enable uchiwa",
    unless => "systemctl is-enabled uchiwa"
  }

#  service { 'uchiwa':
#    ensure => running,
#  }
}
