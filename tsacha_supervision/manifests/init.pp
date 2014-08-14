class tsacha_supervision {
  class { 'tsacha_supervision::install': } ->
  class { 'tsacha_supervision::rabbitmq': } ->
  class { 'tsacha_supervision::elk': } ->
  class { 'tsacha_supervision::flapjack': } ->
  class { 'tsacha_supervision::sensu': } ->

  service { 'rabbitmq-server':
    ensure => running,
    require => Package['rabbitmq-server']
  }

  $redis_ports.each |$value| {
    service { "redis-$value":
      ensure => running,
      hasrestart => false,
      hasstatus => false,
      status => "netstat -natup | grep '0.0.0.0:$value'",
      require => [File["/var/lib/redis/$value"],File['/var/log/redis']]
    }      
  }

}
