class tsacha_dns::trs {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    File {
      ensure => present,
      owner => root,
      group => bind,
      mode => 640,
     }

    file { "/var/lib/named/etc/bind/db.trs.io":
      source => "puppet:///modules/tsacha_dns/trs.io",
      notify => Service['bind9']
    }

}
