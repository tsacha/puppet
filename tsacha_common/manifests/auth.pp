class tsacha_common::auth {

  $kerbin_pubkey = hiera('common::kerbin_pubkey')

  $container = hiera('containers::container')
  if($container == false) {
    file { "/root/.ssh/id_ecdsa":
      owner => root,
      group => root,
      mode => 600,
      ensure => present,
      source => "puppet:///modules/tsacha_private/ssh/$hostname",
    }  

    file { "/root/.ssh/id_ecdsa.pub":
      owner => root,
      group => root,
      mode => 644,
      ensure => present,
      source => "puppet:///modules/tsacha_private/ssh/$hostname.pub",
    }  
  }

  # Compute node will use controller node to resolv dns
  file { "/root/.ssh/authorized_keys":
    owner   => root,
    group   => root,
    mode    => 644,
    ensure  => present,
  }  
 
  file_line { 'kerbin-ssh':
    path => '/root/.ssh/authorized_keys',
    line => "$kerbin_pubkey",
  }

}
