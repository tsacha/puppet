class tsacha_lb {
    class { 'tsacha_lb::install': } ->
    service { 'nginx':
      ensure => running
    }
}