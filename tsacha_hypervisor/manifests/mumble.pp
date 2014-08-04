# mumble.pp
#
# Mumble container generation

class tsacha_hypervisor::mumble {
  include tsacha_hypervisor::network

  require tsacha_hypervisor::dns

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $mumble_cidr = $hosts[$hostname]['physical']['cidr_private']
  $mumble_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $mumble_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $mumble_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $mumble_puppet = $hosts['kerbin']['physical']['fqdn']
  $mumble_ip_puppet = $hosts['kerbin']['physical']['ip']
  $mumble_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $mumble_fqdn = $hosts[$hostname]['mumble']['fqdn']
  $mumble_ip = $hosts[$hostname]['mumble']['ip']
  $mumble_ip6 = $hosts[$hostname]['mumble']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-mumble-container":
    command => "ruby /srv/generate_container.rb --fqdn $mumble_fqdn --ip $mumble_ip --cidr $mumble_cidr --gateway $mumble_gateway --ip6 $mumble_ip6 --cidr6 $mumble_cidr6 --gateway6 $mumble_gateway6 --dns 8.8.8.8 --puppet $mumble_puppet --ippuppet $mumble_ip_puppet --ip6puppet $mumble_ip6_puppet --idhypervisor $idhypervisor --version testing",
    unless => "virsh list --all | grep mumble",
    timeout => 500
  } ->

  exec { "start-mumble-container":
    command => "virsh start mumble",
    unless => "virsh list | grep mumble",
  }

  exec { "mumble-neigh":
    command => "ip -6 neigh add proxy $mumble_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $mumble_ip6 dev br-ex | grep $mumble_ip6"
  }
}