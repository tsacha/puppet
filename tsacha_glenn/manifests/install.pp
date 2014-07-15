class tsacha_glenn::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  include tsacha_web::install

  package { 'php5-gd':
    ensure => installed
  }
  package { 'curl':
    ensure => installed
  }
  package { 'php5-curl':
    ensure => installed
  }

}
