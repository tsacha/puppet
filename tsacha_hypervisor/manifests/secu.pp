class tsacha_hypervisor::secu {

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
  
  if($hostname == "duna") {
    $dns_ip = $hosts[$hostname]['dns']['ip']
    $ldap_ip = $hosts['jool']['ldap']['ip']
    $mail_ip = $hosts['jool']['mail']['ip']
    $psql_ip = $hosts['jool']['psql']['ip']
    $im_ip = $hosts['jool']['im']['ip']
    $web_ip = $hosts['jool']['web']['ip']
  }

  if($hostname == "jool") {
    $dns_ip = $hosts[$hostname]['dns']['ip']
    $ldap_ip = $hosts[$hostname]['ldap']['ip']
    $mail_ip = $hosts[$hostname]['mail']['ip']
    $psql_ip = $hosts[$hostname]['psql']['ip']
    $im_ip = $hosts[$hostname]['im']['ip']
    $web_ip = $hosts[$hostname]['web']['ip']
  }
  
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
    

  $iptablesfile = "/etc/sysconfig/iptables"

  # Postrouting, masquerade
  file { $iptablesfile:
    owner => root,
    group => root,
    mode => '0600',
    ensure => present,
    content => template('tsacha_hypervisor/iptables.up.rules.erb'),
  } ~>
  
  exec { 'iptables-restore':
    command => "iptables-restore < $iptablesfile",
    refreshonly => true
  }

  package { 'iptables-services':
    ensure => installed
  } ->

  service { 'iptables':
    ensure => running
  }

  file { "/etc/selinux/config":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    content => template('tsacha_hypervisor/selinux.config.erb'),
  }    
}


