class tsacha_hypervisor::network {

  $hosts = hiera_hash('hosts')

  $ip_private_range = $hosts[$hostname]['physical']['ip_private_range']
  $ip_private_address = $hosts[$hostname]['physical']['ip_private_address']
  $cidr_private = $hosts[$hostname]['physical']['cidr_private']
  $ip_address = $hosts[$hostname]['physical']['ip']
  $cidr = $hosts[$hostname]['physical']['cidr']
  $gateway = $hosts[$hostname]['physical']['gateway']
  $ip6_address = $hosts[$hostname]['physical']['ip6']
  $cidr6 = $hosts[$hostname]['physical']['cidr6']
  $gateway6 = $hosts[$hostname]['physical']['gateway6']
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/sysctl.conf":
    owner => root,
    group => root,
    mode => 0644,
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
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/interfaces.erb'),
  }

  $hosts.each |$key,$value| {
    if($key != $hostname) {
      $id_local = $hosts[$hostname]['physical']['idhypervisor']
      $id_remote = $hosts[$key]['physical']['idhypervisor']
      if($id_local < $id_remote) {
        $subnet = "${id_local}${id_remote}"
      }
      else {
        $subnet = "${id_remote}${id_local}"
      }


      exec { "create-tunnel-$key":
        command =>  "ip tunnel add $hostname-$key mode gre remote ${hosts[$key]['physical']['ip']} local ${hosts[$hostname]['physical']['ip']} ttl 255",
        unless =>  "ip tunnel | grep $hostname-$key"
      } ->
      exec { "up-tunnel-$key":
        command => "ip link set $hostname-$key up",
        unless => "ip link show $hostname-$key | grep UP"
      } ->
      exec { "addr-tunnel-$key":
        command => "ip address add 10.40.$subnet.${hosts[$hostname]['physical']['idhypervisor']}/24 dev $hostname-$key",
        unless => "ip address show $hostname-$key | grep 10.40.$subnet.${hosts[$hostname]['physical']['idhypervisor']}/24"
      } ->
      exec { "routing-$key":
        command => "ip route add ${hosts[$key]['physical']['ip_private_range']}/${hosts[$key]['physical']['cidr_private']} via 10.40.$subnet.${hosts[$key]['physical']['idhypervisor']}",
        unless => "ip route show | grep \"${hosts[$key]['physical']['ip_private_range']}/${hosts[$key]['physical']['cidr_private']} via 10.40.$subnet.${hosts[$key]['physical']['idhypervisor']}\""
       
      }
    }
  }

}