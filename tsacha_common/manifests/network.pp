class tsacha_common::network {

  $container = hiera('containers::container')
  $hypervisor = hiera('containers::hypervisor')

  file { "/etc/resolv.conf":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_common/resolv.conf.erb'),
  }
  
  if($container) {
    @@file_line { "hosts-$fqdn":
      path => '/etc/hosts',
      line => "$ipaddress6 $fqdn $hostname-$hypervisor"
    }
  }
  else {
    @@file_line { "hosts-$fqdn":
      path => '/etc/hosts',
      line => "$ipaddress6 $fqdn $hostname"
    }
  }

  File_line <<||>>

}
