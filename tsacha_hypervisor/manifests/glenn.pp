# glenn.pp
#
# Glenn container generation

class tsacha_hypervisor::glenn {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::dns'] -> Class['tsacha_hypervisor::glenn']

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $glenn_cidr = $hosts[$hostname]['physical']['cidr_private']
  $glenn_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $glenn_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $glenn_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $glenn_puppet = $hosts['kerbin']['physical']['fqdn']
  $glenn_ip_puppet = $hosts['kerbin']['physical']['ip']
  $glenn_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $glenn_fqdn = $hosts[$hostname]['glenn']['fqdn']
  $glenn_ip = $hosts[$hostname]['glenn']['ip']
  $glenn_ip6 = $hosts[$hostname]['glenn']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-glenn-container":
    command => "ruby /srv/generate_container.rb --fqdn $glenn_fqdn --ip $glenn_ip --cidr $glenn_cidr --gateway $glenn_gateway --ip6 $glenn_ip6 --cidr6 $glenn_cidr6 --gateway6 $glenn_gateway6 --dns 8.8.8.8 --puppet $glenn_puppet --ippuppet $glenn_ip_puppet --ip6puppet $glenn_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep glenn",
    timeout => 500
  } ->

  exec { "start-glenn-container":
    command => "virsh start glenn",
    unless => "virsh list | grep glenn",
  }

  exec { "glenn-neigh":
    command => "ip -6 neigh add proxy $glenn_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $glenn_ip6 dev br-ex | grep $glenn_ip6"
  }
}