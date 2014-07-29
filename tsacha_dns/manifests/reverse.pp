class tsacha_dns::reverse {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    ensure => present,
    owner => root,
    group => bind,
    mode => 0640,
   }

  $hosts = hiera_hash('hosts')
  $hosts.each |$key,$value| {
    $value.each |$hostname,$conf| {
      $host_name = $conf['fqdn']
      $host_address = $conf['ip']
      $host_address6 = $conf['ip6']
      if($hostname == "physical") {
        file { "/var/lib/named/etc/bind/db.$key.reverse.v6":
          content => template('tsacha_dns/reverse6.erb'),
          notify => Service['bind9']
        }

        file { "/var/lib/named/etc/bind/db.$key.reverse.v4":
          content => template('tsacha_dns/reverse4.erb'),
          notify => Service['bind9']
        }
      }
    }
  }
}

