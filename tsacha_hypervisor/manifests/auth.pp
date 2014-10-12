class tsacha_hypervisor::auth {

  file { "/root/.ssh/id_ecdsa":
    owner => root,
    group => root,
    mode => '0600',
    ensure => present,
    source => "puppet:///modules/tsacha_private/ssh/$hostname",
  }  

  file { "/root/.ssh/id_ecdsa.pub":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    source => "puppet:///modules/tsacha_private/ssh/$hostname.pub",
  }

}