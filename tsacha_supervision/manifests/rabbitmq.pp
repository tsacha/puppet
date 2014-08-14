class tsacha_supervision::rabbitmq {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/rabbitmq/rabbitmq.config":
    ensure => present,
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0664,
    content => template('tsacha_supervision/rabbitmq/rabbitmq.config.erb'),
    require => Package['rabbitmq-server'],
    notify => Service['rabbitmq-server']
  }


  file { "/etc/rabbitmq/ssl":
    ensure => directory,
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0700,
    require => Package['rabbitmq-server']
  }

  file { "/etc/rabbitmq/ssl/cacert.pem":
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0600,
    source => "puppet:///modules/tsacha_private/autosign/tsacha_ca/cacert.pem",
    require => File['/etc/rabbitmq/ssl'],
    notify => Service['rabbitmq-server']
  }  

  file { "/etc/rabbitmq/ssl/server_cert.pem":
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0600,
    source => "puppet:///modules/tsacha_private/autosign/rabbitmq_cert.pem",
    require => File['/etc/rabbitmq/ssl'],
    notify => Service['rabbitmq-server']
  }  

  file { "/etc/rabbitmq/ssl/server_key.pem":
    owner => rabbitmq,
    group => rabbitmq,
    mode => 0400,
    source => "puppet:///modules/tsacha_private/autosign/rabbitmq_key.pem",
    require => File['/etc/rabbitmq/ssl'],
    notify => Service['rabbitmq-server']
  }  
}