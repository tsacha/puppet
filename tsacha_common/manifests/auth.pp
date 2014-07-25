class tsacha_common::auth {

  $pubkeys = hiera('pubkeys')

  # Compute node will use controller node to resolv dns
  file { "/root/.ssh/authorized_keys":
    owner   => root,
    group   => root,
    mode    => 0644,
    ensure  => present,
  }  
}
