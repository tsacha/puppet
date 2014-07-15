class tsacha_dns::terres-creuses {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    File {
      ensure => present,
      owner => root,
      group => bind,
      mode => 640,
     }

    file { "/var/lib/named/etc/bind/db.terres-creuses.fr":
      source => "puppet:///modules/tsacha_dns/terres-creuses.fr",
      notify => Service['bind9']
    }
}
