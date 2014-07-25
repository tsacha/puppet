class tsacha_dns::glenn {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    File {
      ensure => present,
      owner => root,
      group => bind,
      mode => 0640,
     }

    file { "/var/lib/named/etc/bind/db.glenn-s.eu":
      source => "puppet:///modules/tsacha_dns/glenn-s.eu",
      notify => Service['bind9']
    }

    file { "/var/lib/named/etc/bind/db.glenn.pro":
      source => "puppet:///modules/tsacha_dns/glenn.pro",
      notify => Service['bind9']
    }

}
