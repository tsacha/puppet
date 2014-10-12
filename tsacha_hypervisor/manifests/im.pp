# im.pp
#
# Im container generation

class tsacha_hypervisor::im {
  include tsacha_hypervisor::network

  require tsacha_hypervisor::ldap

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $im_cidr = $hosts[$hostname]['physical']['cidr_private']
  $im_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $im_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $im_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $im_puppet = $hosts['kerbin']['physical']['fqdn']
  $im_ip_puppet = $hosts['kerbin']['physical']['ip']
  $im_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $im_fqdn = $hosts[$hostname]['im']['fqdn']
  $im_ip = $hosts[$hostname]['im']['ip']
  $im_ip6 = $hosts[$hostname]['im']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-im-container":
    command => "ruby /srv/generate_container.rb --fqdn '$im_fqdn' --ip $im_ip --cidr $im_cidr --gateway $im_gateway --ip6 $im_ip6 --cidr6 $im_cidr6 --gateway6 $im_gateway6 --dns 8.8.8.8 --puppet $im_puppet --ippuppet $im_ip_puppet --ip6puppet $im_ip6_puppet --idhypervisor $idhypervisor --version testing",
    unless => "virsh list --all | grep im",
    timeout => 500
  } ->

  exec { "start-im-container":
    command => "virsh start im",
    unless => "virsh list | grep im",
  }

  exec { "im-neigh":
    command => "ip -6 neigh add proxy $im_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $im_ip6 dev br-ex | grep $im_ip6"
  }
}