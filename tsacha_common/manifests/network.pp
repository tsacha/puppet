class tsacha_common::network {
  file { "/etc/resolv.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/resolv.conf.erb'),
  }

  $hosts = hiera_hash('hosts')
  $hosts.each |$key,$value| {
    $value.each |$hostname,$conf| {
      $host_name = $conf['fqdn']
      $host_address = $conf['ip']
      $host_address6 = $conf['ip6']
      if($hostname != "physical") {
        $domain_split = split($conf['fqdn'], '[.]')
        $short = "$hostname-${domain_split[1]}"
      } else {
        $short = $key
      }
      host { $host_name:
        name => $host_name,
        ip => $host_address6,
        host_aliases => $short,
      }


    }

  }

  
}
