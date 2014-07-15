class tsacha_hypervisor::fw {

  $ip_private_range = hiera('network::ip_private_range')
  $ip_private_address = hiera('network::ip_private_address')
  $cidr_private = hiera('network::cidr_private')
  $ip_address = hiera('network::ip_address')
  $cidr = hiera('network::cidr')
  $gateway = hiera('network::gateway')
  $ip6_address = hiera('network::ip6_address')
  $cidr6 = hiera('network::cidr6')
  $gateway6 = hiera('network::gateway6')
  $dns_ip = hiera('dns::ip')
  $ldap_ip = hiera('ldap::ip')
  $mail_ip = hiera('mail::ip')
  $psql_ip = hiera('psql::ip')
  $im_ip = hiera('im::ip')
  $web_ip = hiera('web::ip')
  $glenn_ip = hiera('glenn::ip')
  
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


