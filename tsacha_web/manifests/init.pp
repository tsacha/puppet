class tsacha_web {
    class { 'tsacha_web::install': } ->
    class { 'tsacha_web::certs': } ->
    class { 'tsacha_web::sacha': } ->
    class { 'tsacha_web::glenn': } ->
    class { 'tsacha_web::tc': } ->
    class { 'tsacha_web::autoconfig': } ->
    class { 'tsacha_web::webmail': }

    service { 'apache2':
      ensure => running,
      require => Package['apache2'],
    }
}