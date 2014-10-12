# generic.pp
#
# Generic container generation

define tsacha_hypervisor::generic {
  $cont = $name
  include tsacha_hypervisor::network

  require tsacha_hypervisor::auth
  require tsacha_hypervisor::lxc

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $cidr = $hosts[$hostname]['physical']['cidr_private']
  $cidr6 = $hosts[$hostname]['physical']['cidr6']
  $gateway = $hosts[$hostname]['physical']['ip_private_address']
  $gateway6 = $hosts[$hostname]['physical']['gateway6']
  $puppet = $hosts['kerbin']['physical']['fqdn']
  $ip_puppet = $hosts['kerbin']['physical']['ip']
  $ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $fqdn = $hosts[$hostname][$cont]['fqdn']
  $ip = $hosts[$hostname][$cont]['ip']
  $ip6 = $hosts[$hostname][$cont]['ip6']
  $version = $hosts[$hostname][$cont]['version']

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-$cont-container":
    command => "ruby /srv/generate_container.rb --fqdn $fqdn --ip $ip --cidr $cidr --gateway $gateway --ip6 $ip6 --cidr6 $cidr6 --gateway6 $gateway6 --dns 8.8.8.8 --puppet $puppet --ippuppet $ip_puppet --ip6puppet $ip6_puppet --idhypervisor $idhypervisor --version $version",
    unless => "lxc-ls | grep $cont",
    timeout => 500
  }

   file { "/usr/lib/systemd/system/$cont.service":
     ensure => present,
     mode => '0644',
     owner => root,
     group => root,
     content => template('tsacha_hypervisor/container.service.erb'),
   }

#  exec { "start-$cont-container":
#    command => "lxc-start -n $cont -d",
#    unless => "lxc-info -n $cont | grep STARTED",
#    require => Exec['generate-$cont-container']
#  }
#

#  exec { 'provisioning-$cont':
#    command => "ssh -o StrictHostKeyChecking=no $ip6 -C 'puppet agent -t'",
#    returns => 2,
#    timeout => 1200,
#    require => "stat /var/lib/lxc/$cont/rootfs/etc/systemd/system/multi-user.target.wants/puppet.service",
#    require => Exec['start-$cont-container']
#  }
}
