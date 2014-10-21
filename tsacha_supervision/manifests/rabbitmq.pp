class tsacha_supervision::rabbitmq {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/rabbitmq/ssl":
    ensure => directory,
    owner => rabbitmq,
    group => rabbitmq,
    mode => "0755",
  }

  file { "/etc/rabbitmq/ssl/cacert.pem":
    ensure => present,
    owner => rabbitmq,
    group => rabbitmq,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/tsacha_ca/cacert.pem",
    require => File['/etc/rabbitmq/ssl']
  }

  file { "/etc/rabbitmq/ssl/cert.pem":
    ensure => present,
    owner => rabbitmq,
    group => rabbitmq,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/rabbitmq_cert.pem",
    require => File['/etc/rabbitmq/ssl']
  }

  file { "/etc/rabbitmq/ssl/key.pem":
    ensure => present,
    owner => rabbitmq,
    group => rabbitmq,
    mode => "0400",
    source => "puppet:///modules/tsacha_private/autosign/rabbitmq_key.pem",
    require => File['/etc/rabbitmq/ssl']
  }

  file { "/etc/rabbitmq/rabbitmq.config":
    ensure => present,
    owner => rabbitmq,
    group => rabbitmq,
    mode => "0644",
    content => template('tsacha_supervision/rabbitmq.config.erb'),
    notify => Service['rabbitmq-server']
  }

}
