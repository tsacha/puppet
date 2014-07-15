# web.pp
#
# Web container generation

class tsacha_hypervisor::web {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::im'] -> Class['tsacha_hypervisor::web']

  $idhypervisor = hiera('containers::idhypervisor')
  $web_cidr = hiera('containers::cidr')
  $web_cidr6 = hiera('containers::cidr6')
  $web_gateway = hiera('containers::gateway')
  $web_gateway6 = hiera('containers::gateway6')
  $web_puppet = hiera('containers::puppet')
  $web_ip_puppet = hiera('containers::ip_puppet')
  $web_ip6_puppet = hiera('containers::ip6_puppet')
  $web_fqdn = hiera('containers::fqdn')
  $web_hostname = hiera('web::hostname')
  $web_ip = hiera('web::ip')
  $web_ip6 = hiera('web::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-web-container":
    command => "ruby /srv/generate_container.rb --hostname $web_hostname --domain $fqdn --ip $web_ip --cidr $web_cidr --gateway $web_gateway --ip6 $web_ip6 --cidr6 $web_cidr6 --gateway6 $web_gateway6 --dns 8.8.8.8 --puppet $web_puppet --ippuppet $web_ip_puppet --ip6puppet $web_ip6_puppet --idhypervisor $idhypervisor --version testing",
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