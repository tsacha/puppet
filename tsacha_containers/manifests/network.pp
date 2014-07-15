class tsacha_containers::network {
  $hosts = hiera_hash('hosts')
  $domain_split = split($domain, '[.]')
  $hypervisor = $domain_split[0]

  $ip_address = $hosts[$hypervisor][$hostname]['ip']
  $cidr = $hosts[$hypervisor]['physical']['cidr_private']
  $gateway = $hosts[$hypervisor]['physical']['ip_private_address']
  $ip6_address = $hosts[$hypervisor][$hostname]['ip6']
  $cidr6 = $hosts[$hypervisor]['physical']['cidr6']
  $gateway6 = $hosts[$hypervisor]['physical']['gateway6']
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/network/interfaces":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_containers/interfaces.erb')
  }

}


