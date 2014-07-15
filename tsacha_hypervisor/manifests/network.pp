class tsacha_hypervisor::network {

  $ip_private_range = hiera('network::ip_private_range')
  $ip_private_address = hiera('network::ip_private_address')
  $cidr_private = hiera('network::cidr_private')
  $ip_address = hiera('network::ip_address')
  $cidr = hiera('network::cidr')
  $gateway = hiera('network::gateway')
  $ip6_address = hiera('network::ip6_address')
  $cidr6 = hiera('network::cidr6')
  $gateway6 = hiera('network::gateway6')
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/sysctl.conf":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_hypervisor/sysctl.conf.erb'),
    notify => Exec['apply-sysctl']
  }
  exec { "apply-sysctl":
    command => "sysctl -p",
    refreshonly => true
  }

  exec { 'create-intern-bridge':
    command => "ip link add br-int type bridge",
    unless => 'ip link show br-int',
  }

  exec { "addr-intern-bridge":
    command => "ip address add $ip_private_address/$cidr_private dev br-int",
    unless => "ip address show br-int | grep $ip_private_address/$cidr_private",
    require => Exec["create-intern-bridge"]
  }

  exec { 'create-extern-bridge':
    command => "ip link add br-ex type bridge",
    unless => 'ip link show br-ex',
  }

  exec { "addr-extern-bridge":
    command => "ip address add $ip_address/$cidr dev br-ex",
    unless => "ip address show br-ex | grep $ip_address/$cidr",
    require => Exec["create-extern-bridge"]
  }

  # Add current IPv6 address to the bridge
  exec { "addr6-extern-bridge":
    command => "ip -6 address add $ip6_address/$cidr6 dev br-ex",
    unless => "ip -6 address show br-ex | grep $ip6_address/$cidr6",
    require => Exec["create-extern-bridge"]
  }

  # Add current IPv6 address to the bridge
  exec { "route-gateway6":
    command => "ip -6 route delete $gateway6 dev eth0; ip -6 route add $gateway6 dev br-ex",
    unless => "ip -6 route show $gateway6 dev br-ex | grep $gateway6",
    require => Exec["create-extern-bridge"]
  }

  exec { "up-extern-bridge":
    command => "ip link set br-ex up",
    unless => "ip link show br-ex | grep UP",
    require => Exec["create-extern-bridge"]
  }

 # Use bridge
  exec { "switch-bridge":
    command => "ip link set eth0 master br-ex; ip route del default via $gateway dev eth0; ip route add default via $gateway dev br-ex",
    unless => "ip route list 0/0 | grep br-ex",
    require => [Exec["addr-extern-bridge"],Exec["up-extern-bridge"]]
  }

  exec { "rm-addr-origin":
    command => "ip address flush dev eth0; ip route flush dev eth0",
    onlyif => "ip address show eth0 | grep $ip_address/$cidr",
    require => Exec["switch-bridge"]
  }

  exec { "rm-addr6-origin":
    command => "ip -6 address delete $ip6_address/$cidr6 dev eth0",
    onlyif => "ip -6 address show eth0 | grep $ip6_address/$cidr6",
    require => Exec["switch6-bridge"]
  }

  # Use bridge with IPv6
  exec { "switch6-bridge":
    command => "ip -6 route del default via $gateway6 dev eth0; ip route add default via $gateway6 dev br-ex",
    unless => "ip -6 route list | grep default | grep br-ex",
    require => [Exec["addr-extern-bridge"],Exec["up-extern-bridge"],Exec["route-gateway6"]]
  }

  file { "/etc/network/interfaces":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_hypervisor/interfaces.erb'),
  }

}


