class tsacha_lb::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'nginx':
    ensure => installed
  }  

  service { 'httpd':
  }

  file { '/etc/httpd/conf.d/welcome.conf':
    ensure => absent,
    notify => Service['httpd']
  }


  file { "/etc/httpd/conf.d/ssl.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => [Service['httpd'],Service['nginx']],
    content => template('tsacha_lb/ssl.conf.erb'),
  }

  file { "/etc/nginx/conf.d/default.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => Service['nginx'],
    content => template('tsacha_lb/nginx.erb'),
  }

  file { "/etc/httpd/conf/httpd.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => [Service['httpd'],Service['nginx']],
    content => template('tsacha_lb/httpd.conf.erb'),
  }

}
