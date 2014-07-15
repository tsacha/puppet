# im.pp
#
# Im container generation

class tsacha_hypervisor::im {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::psql'] -> Class['tsacha_hypervisor::im']

  $idhypervisor = hiera('containers::idhypervisor')
  $im_cidr = hiera('containers::cidr')
  $im_cidr6 = hiera('containers::cidr6')
  $im_gateway = hiera('containers::gateway')
  $im_gateway6 = hiera('containers::gateway6')
  $im_puppet = hiera('containers::puppet')
  $im_ip_puppet = hiera('containers::ip_puppet')
  $im_ip6_puppet = hiera('containers::ip6_puppet')
  $im_fqdn = hiera('containers::fqdn')
  $im_hostname = hiera('im::hostname')
  $im_ip = hiera('im::ip')
  $im_ip6 = hiera('im::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-im-container":
    command => "ruby /srv/generate_container.rb --hostname $im_hostname --domain $fqdn --ip $im_ip --cidr $im_cidr --gateway $im_gateway --ip6 $im_ip6 --cidr6 $im_cidr6 --gateway6 $im_gateway6 --dns 8.8.8.8 --puppet $im_puppet --ippuppet $im_ip_puppet --ip6puppet $im_ip6_puppet --idhypervisor $idhypervisor --version testing",
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