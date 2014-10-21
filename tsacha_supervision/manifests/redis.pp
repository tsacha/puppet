class tsacha_supervision::redis {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  if($hostname == "kerbin") {
    $ip_private_address = $hosts[$hostname]['physical']['ip_private_address']
    $ip_address = $hosts[$hostname]['physical']['ip']
    $ip6_address = $hosts[$hostname]['physical']['ip6']
  }
  else {
    $domain_split = split($domain, '[.]')
    $hypervisor = $domain_split[0]
  
    $ip_private_address = $hosts[$hypervisor][$hostname]['ip']
    $ip6_address = $hosts[$hypervisor][$hostname]['ip6']
  }

  file { "/etc/redis.conf":
    ensure => present,
    owner => redis,
    group => redis,
    mode => "0644",
    content => template('tsacha_supervision/redis.config.erb'),
    notify => Service['redis']
  }

}
