class tsacha_dns::tremoureux {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    ensure => present,
    owner => root,
    group => named,
    mode => '0640',
   }

  file { "/etc/named/tremoureux.fr.ksk.private":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.ksk.private",
    mode => '0400'
  } ->

  file { "/etc/named/tremoureux.fr.ksk.key":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.ksk.key",
  } ->

  file { "/etc/named/tremoureux.fr.zsk.private":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.zsk.private",
    mode => '0400'
  } ->

  file { "/etc/named/tremoureux.fr.zsk.key":
    source => "puppet:///modules/tsacha_private/dns/tremoureux.fr.zsk.key",
  } ->

  file { "/var/named/db.tremoureux.fr":
    content => template('tsacha_dns/tremoureux.fr.erb'),
  } ->

  exec { "sign-zone":
    command => "dnssec-signzone -e $(date -d '+2 years' '+%Y%m%d130000') -p -t -g -k /etc/named/tremoureux.fr.ksk.key -o tremoureux.fr db.tremoureux.fr /etc/named/tremoureux.fr.zsk.key",
    cwd => "/var/named",
    unless => "test $(cat db.tremoureux.fr.signed | grep -A1 'IN SOA' | tail -n 1 | awk '{print \$1}') -eq $(cat db.tremoureux.fr | grep -A1 'IN SOA' | tail -n 1 | awk '{print \$1}')",
    require => File["/var/named/db.tremoureux.fr"],
    notify => Service["named"]
  }

}
