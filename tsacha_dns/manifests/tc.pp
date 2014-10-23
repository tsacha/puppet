class tsacha_dns::tc {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  $fronts = hiera_hash('fronts')  

  File {
    ensure => present,
    owner => root,
    group => named,
    mode => '0640',
   }

  file { "/var/named/db.terres-creuses.fr":
    content => template('tsacha_dns/terres-creuses.fr.erb'),
    notify => Service['named']
  }
}
