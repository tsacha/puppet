class tsacha_dns::glenn {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  $fronts = hiera_hash('fronts')  

  File {
    ensure => present,
    owner => root,
    group => named,
    mode => '0640',
   }

  file { "/var/named/db.glenn-s.eu":
    content => template('tsacha_dns/glenn-s.eu.erb'),
    notify => Service['named']
  }

  file { "/var/named/db.glenn.pro":
    content => template('tsacha_dns/glenn.pro.erb'),      
    notify => Service['named']
  }

}
