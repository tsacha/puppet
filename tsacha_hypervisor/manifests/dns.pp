# dns.pp
#
# DNS container generation

class tsacha_hypervisor::dns {
  include tsacha_hypervisor::network

  Class['tsacha_common::auth'] -> Class['tsacha_hypervisor::lxc'] -> Class['tsacha_hypervisor::dns']

  $idhypervisor = hiera('containers::idhypervisor')
  $dns_cidr = hiera('containers::cidr')
  $dns_cidr6 = hiera('containers::cidr6')
  $dns_gateway = hiera('containers::gateway')
  $dns_gateway6 = hiera('containers::gateway6')
  $dns_puppet = hiera('containers::puppet')
  $dns_ip_puppet = hiera('containers::ip_puppet')
  $dns_ip6_puppet = hiera('containers::ip6_puppet')
  $dns_fqdn = hiera('containers::fqdn')
  $dns_hostname = hiera('dns::hostname')
  $dns_ip = hiera('dns::ip')
  $dns_ip6 = hiera('dns::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  define device_node($type="c",$major,$minor,$mode) {
    exec { "create-device-${name}":
      command => "mknod -m ${mode} ${name} ${type} ${major} ${minor}",
      path => "/bin",
      creates => $name,
    }
  }

  exec { "generate-dns-container":
    command => "ruby /srv/generate_container.rb --hostname $dns_hostname --domain $fqdn --ip $dns_ip --cidr $dns_cidr --gateway $dns_gateway --ip6 $dns_ip6 --cidr6 $dns_cidr6 --gateway6 $dns_gateway6 --dns 8.8.8.8 --puppet $dns_puppet --ippuppet $dns_ip_puppet --ip6puppet $dns_ip6_puppet --idhypervisor $idhypervisor --version testing",
    unless => "virsh list --all | grep dns",
    timeout => 500
  } ->

  file { ["/var/lib/lxc/dns/rootfs/var/lib/named/","/var/lib/lxc/dns/rootfs/var/lib/named/dev"]:
    ensure  => directory,
  } ->

  device_node { "/var/lib/lxc/dns/rootfs/var/lib/named/dev/null":
    type => c,
    major => 1,
    minor => 3,
    mode => 0666,
  } ->

  device_node { "/var/lib/lxc/dns/rootfs/var/lib/named/dev/random":
    type => c,
    major => 1,
    minor => 8,
    mode => 0666
  } ->

  exec { "start-dns-container":
    command => "virsh start dns",
    unless => "virsh list | grep dns",
    require => [Device_node["/var/lib/lxc/dns/rootfs/var/lib/named/dev/random","/var/lib/lxc/dns/rootfs/var/lib/named/dev/null"]]
  }

  exec { "dns-neigh":
    command => "ip -6 neigh add proxy $dns_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $dns_ip6 dev br-ex | grep $dns_ip6"
  }

  exec { 'provisioning-dns':
    command => "ssh -o StrictHostKeyChecking=no $dns_ip6 -C 'puppet agent -t'",
    returns => 2,
    timeout => 1200,
    unless => "ssh -o StrictHostKeyChecking=no $dns_ip6 -C 'cat /etc/default/puppet | grep START=yes'",
    require => [Exec['start-dns-container'],Exec['dns-neigh']]
  }
}