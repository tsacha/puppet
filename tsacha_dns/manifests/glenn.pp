class tsacha_dns::glenn {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    File {
      ensure => present,
      owner => root,
      group => named,
      mode => '0640',
     }

    file { "/var/named/db.glenn-s.eu":
      source => "puppet:///modules/tsacha_dns/glenn-s.eu",
      notify => Service['named']
    }

    file { "/var/named/db.glenn.pro":
      source => "puppet:///modules/tsacha_dns/glenn.pro",
      notify => Service['named']
    }

}
