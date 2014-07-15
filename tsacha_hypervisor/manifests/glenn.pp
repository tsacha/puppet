# glenn.pp
#
# Glenn container generation

class tsacha_hypervisor::glenn {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::im'] -> Class['tsacha_hypervisor::glenn']

  $idhypervisor = hiera('containers::idhypervisor')
  $glenn_cidr = hiera('containers::cidr')
  $glenn_cidr6 = hiera('containers::cidr6')
  $glenn_gateway = hiera('containers::gateway')
  $glenn_gateway6 = hiera('containers::gateway6')
  $glenn_puppet = hiera('containers::puppet')
  $glenn_ip_puppet = hiera('containers::ip_puppet')
  $glenn_ip6_puppet = hiera('containers::ip6_puppet')
  $glenn_fqdn = hiera('containers::fqdn')
  $glenn_hostname = hiera('glenn::hostname')
  $glenn_ip = hiera('glenn::ip')
  $glenn_ip6 = hiera('glenn::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-glenn-container":
    command => "ruby /srv/generate_container.rb --hostname $glenn_hostname --domain $fqdn --ip $glenn_ip --cidr $glenn_cidr --gateway $glenn_gateway --ip6 $glenn_ip6 --cidr6 $glenn_cidr6 --gateway6 $glenn_gateway6 --dns 8.8.8.8 --puppet $glenn_puppet --ippuppet $glenn_ip_puppet --ip6puppet $glenn_ip6_puppet --idhypervisor $idhypervisor --version testing",
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