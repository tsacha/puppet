# web.pp
#
# Web container generation

class tsacha_hypervisor::web {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::dns'] -> Class['tsacha_hypervisor::web']

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $web_cidr = $hosts[$hostname]['physical']['cidr_private']
  $web_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $web_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $web_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $web_puppet = $hosts['kerbin']['physical']['fqdn']
  $web_ip_puppet = $hosts['kerbin']['physical']['ip']
  $web_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $web_fqdn = $hosts[$hostname]['web']['fqdn']
  $web_ip = $hosts[$hostname]['web']['ip']
  $web_ip6 = $hosts[$hostname]['web']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-web-container":
    command => "ruby /srv/generate_container.rb --fqdn $web_fqdn --ip $web_ip --cidr $web_cidr --gateway $web_gateway --ip6 $web_ip6 --cidr6 $web_cidr6 --gateway6 $web_gateway6 --dns 8.8.8.8 --puppet $web_puppet --ippuppet $web_ip_puppet --ip6puppet $web_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep web",
    timeout => 500
  } ->

  exec { "start-web-container":
    command => "virsh start web",
    unless => "virsh list | grep web",
  }

  exec { "web-neigh":
    command => "ip -6 neigh add proxy $web_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $web_ip6 dev br-ex | grep $web_ip6"
  }
}