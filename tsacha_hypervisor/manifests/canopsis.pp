# canopsis.pp
#
# Canopsis container generation

class tsacha_hypervisor::canopsis {
  include tsacha_hypervisor::network

  require tsacha_hypervisor::dns

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $canopsis_cidr = $hosts[$hostname]['physical']['cidr_private']
  $canopsis_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $canopsis_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $canopsis_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $canopsis_puppet = $hosts['kerbin']['physical']['fqdn']
  $canopsis_ip_puppet = $hosts['kerbin']['physical']['ip']
  $canopsis_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $canopsis_fqdn = $hosts[$hostname]['canopsis']['fqdn']
  $canopsis_ip = $hosts[$hostname]['canopsis']['ip']
  $canopsis_ip6 = $hosts[$hostname]['canopsis']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-canopsis-container":
    command => "ruby /srv/generate_container.rb --fqdn $canopsis_fqdn --ip $canopsis_ip --cidr $canopsis_cidr --gateway $canopsis_gateway --ip6 $canopsis_ip6 --cidr6 $canopsis_cidr6 --gateway6 $canopsis_gateway6 --dns 8.8.8.8 --puppet $canopsis_puppet --ippuppet $canopsis_ip_puppet --ip6puppet $canopsis_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep canopsis",
    timeout => 500
  } ->

  exec { "start-canopsis-container":
    command => "virsh start canopsis",
    unless => "virsh list | grep canopsis",
  }

  exec { "canopsis-neigh":
    command => "ip -6 neigh add proxy $canopsis_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $canopsis_ip6 dev br-ex | grep $canopsis_ip6"
  }
}