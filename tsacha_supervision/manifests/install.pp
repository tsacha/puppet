class tsacha_supervision::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { "redis":
    ensure => installed
  }

  package { "rabbitmq-server":
    ensure => installed
  }

}
