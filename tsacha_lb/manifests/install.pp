class tsacha_lb::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'nginx':
    ensure => installed
  }  

  file { "/etc/nginx/conf.d/default.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => Service['nginx'],
    content => template('tsacha_lb/nginx.erb'),
  }

}
