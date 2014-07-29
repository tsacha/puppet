class tsacha_dns::trs {

  $hosts = hiera_hash('hosts')
  $fronts = hiera_hash('fronts')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    ensure => present,
    owner => root,
    group => bind,
    mode => 0640,
   }

  file { "/var/lib/named/etc/bind/db.trs.io":
    content => template('tsacha_dns/trs.io.erb'),
    notify => Service['bind9']
  }

}
