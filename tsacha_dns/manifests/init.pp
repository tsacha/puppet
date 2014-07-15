class tsacha_dns {
    class { 'tsacha_dns::install': } ->
    class { 'tsacha_dns::tremoureux': } ->
    class { 'tsacha_dns::trs': } ->
    class { 'tsacha_dns::glenn': } ->
    class { 'tsacha_dns::terres-creuses': } ->
    class { 'tsacha_dns::reverse': } ->
    
    service { 'bind9':
      ensure => running
    }
}