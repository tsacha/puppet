class tsacha_mumble::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'mumble-server':
    ensure => installed
  }
}
