class tsacha_supervision::flapjack {

  Exec { path => [ "/opt/rabbitmq/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { 'install-flapjack':
    command => "gem install flapjack",
    unless => "gem list -i ^flapjack$",
    timeout => 2000
  }

  exec { 'install-flapjack-dinner':
    command => "gem install flapjack-dinner",
    unless => "gem list -i ^flapjack-dinner$",
    timeout => 2000
  }  

}
