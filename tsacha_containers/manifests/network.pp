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
  $provider = $hosts[$hypervisor]['physical']['provider']  
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/sysconfig/network-scripts/ifcfg-eth0":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    content => template('tsacha_containers/eth0.erb')
  }

  file { "/etc/sysconfig/network-scripts/ifcfg-eth1":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    content => template('tsacha_containers/eth1.erb')
  }

  if($provider == "ovh") {
    file { "/sbin/ifup-local":
      owner => root,
      group => root,
      mode => '0755',
      ensure => present,
      content => template('tsacha_containers/ifup.centos'),
    }
  }  

  file { "/etc/sysconfig/network":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    content => template('tsacha_containers/network.erb')
  }

}


