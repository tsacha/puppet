class tsacha_hypervisor::fw {

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

  $dns_ip = $hosts[$hostname]['dns']['ip']
  $ldap_ip = $hosts[$hostname]['ldap']['ip']
  $mail_ip = $hosts[$hostname]['mail']['ip']
  $psql_ip = $hosts[$hostname]['psql']['ip']
  $im_ip = $hosts[$hostname]['im']['ip']
  $web_ip = $hosts[$hostname]['web']['ip']
  $glenn_ip = $hosts[$hostname]['glenn']['ip']
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  # Postrouting, masquerade
  file { "/etc/iptables.up.rules":
    owner => root,
    group => root,
    mode => 600,
    ensure => present,
    content => template('tsacha_hypervisor/iptables.up.rules.erb'),
  } ~>
  
  exec { 'iptables-restore':
    command => "iptables-restore < '/etc/iptables.up.rules'",
    refreshonly => true
  }
    
  file { "/etc/network/if-pre-up.d/iptables":
    owner => root,
    group => root,
    mode => 700,
    ensure => present,
    content => template('tsacha_hypervisor/network_iptables.erb'),
  }

}


