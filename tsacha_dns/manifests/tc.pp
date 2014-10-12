class tsacha_dns::tc {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    ensure => present,
    owner => root,
    group => named,
    mode => '0640',
   }

  file { "/var/named/db.terres-creuses.fr":
    source => "puppet:///modules/tsacha_dns/terres-creuses.fr",
    notify => Service['named']
  }
}
