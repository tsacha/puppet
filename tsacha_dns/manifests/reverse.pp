class tsacha_dns::reverse {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    File {
      ensure => present,
      owner => root,
      group => bind,
      mode => 640,
     }

    file { "/var/lib/named/etc/bind/db.bergen.reverse.v4":
      source => "puppet:///modules/tsacha_dns/bergen.reverse.v4",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.bergen.fallback.reverse.v4":
      source => "puppet:///modules/tsacha_dns/bergen.fallback.reverse.v4",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.oslo.reverse.v4":
      source => "puppet:///modules/tsacha_dns/oslo.reverse.v4",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.tromso.reverse.v4":
      source => "puppet:///modules/tsacha_dns/tromso.reverse.v4",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.bergen.reverse.v6":
      source => "puppet:///modules/tsacha_dns/bergen.reverse.v6",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.oslo.reverse.v6":
      source => "puppet:///modules/tsacha_dns/oslo.reverse.v6",
      notify => Service['bind9']
    }
    file { "/var/lib/named/etc/bind/db.tromso.reverse.v6":
      source => "puppet:///modules/tsacha_dns/tromso.reverse.v6",
      notify => Service['bind9']
    }

}
