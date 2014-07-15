class tsacha_common::auth {

  $pubkeys = hiera('pubkeys')

  # Compute node will use controller node to resolv dns
  file { "/root/.ssh/authorized_keys":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
  }  
 
  define ssh-authorized($file) {
    file_line { "ssh-authorized-$file":
      path => '/root/.ssh/authorized_keys',
      line => file($file)
    }
  }
  create_resources(ssh-authorized, $pubkeys)
}
