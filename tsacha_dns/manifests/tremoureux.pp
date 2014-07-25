class tsacha_dns::tremoureux {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    ensure => present,
    owner => root,
    group => bind,
    mode => 0640,
   }

  file { "/var/lib/named/etc/bind/tremoureux.fr.ksk.private":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.ksk.private",
    mode => 0400
  } ->

  file { "/var/lib/named/etc/bind/tremoureux.fr.ksk.key":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.ksk.key",
  } ->

  file { "/var/lib/named/etc/bind/tremoureux.fr.zsk.private":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.zsk.private",
    mode => 0400
  } ->

  file { "/var/lib/named/etc/bind/tremoureux.fr.zsk.key":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.zsk.key",
  } ->

  file { "/var/lib/named/etc/bind/db.tremoureux.fr":
    content => template('tsacha_dns/tremoureux.fr.erb'),
  } ->

  file { "/etc/bind/tremoureux.fr.zsk.key":
    ensure => link,
    target => "/var/lib/named/etc/bind/tremoureux.fr.zsk.key"
  } ->

  file { "/etc/bind/tremoureux.fr.ksk.key":
    ensure => link,
    target => "/var/lib/named/etc/bind/tremoureux.fr.ksk.key"
  } ->

  exec { "sign-zone":
    command => "dnssec-signzone -e $(date -d '+2 years' '+%Y%m%d130000') -p -t -g -k tremoureux.fr.ksk.key -o tremoureux.fr db.tremoureux.fr tremoureux.fr.zsk.key",
    cwd => "/var/lib/named/etc/bind",
    unless => "test $(cat db.tremoureux.fr.signed | grep -A1 'IN SOA' | tail -n 1 | awk '{print \$1}') -eq $(cat db.tremoureux.fr | grep -A1 'IN SOA' | tail -n 1 | awk '{print \$1}')",
    require => File["/var/lib/named/etc/bind/db.tremoureux.fr"],
    notify => Service["bind9"]
  }

}
