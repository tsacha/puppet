# ldap.pp
#
# Ldap container generation

class tsacha_hypervisor::ldap {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::dns'] -> Class['tsacha_hypervisor::ldap']

  $idhypervisor = hiera('containers::idhypervisor')
  $ldap_cidr = hiera('containers::cidr')
  $ldap_cidr6 = hiera('containers::cidr6')
  $ldap_gateway = hiera('containers::gateway')
  $ldap_gateway6 = hiera('containers::gateway6')
  $ldap_puppet = hiera('containers::puppet')
  $ldap_ip_puppet = hiera('containers::ip_puppet')
  $ldap_ip6_puppet = hiera('containers::ip6_puppet')
  $ldap_fqdn = hiera('containers::fqdn')
  $ldap_hostname = hiera('ldap::hostname')
  $ldap_ip = hiera('ldap::ip')
  $ldap_ip6 = hiera('ldap::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-ldap-container":
    command => "ruby /srv/generate_container.rb --hostname $ldap_hostname --domain $fqdn --ip $ldap_ip --cidr $ldap_cidr --gateway $ldap_gateway --ip6 $ldap_ip6 --cidr6 $ldap_cidr6 --gateway6 $ldap_gateway6 --dns 8.8.8.8 --puppet $ldap_puppet --ippuppet $ldap_ip_puppet --ip6puppet $ldap_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep ldap",
    timeout => 500
  } ->

  exec { "start-ldap-container":
    command => "virsh start ldap",
    unless => "virsh list | grep ldap",
  }

  exec { "ldap-neigh":
    command => "ip -6 neigh add proxy $ldap_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $ldap_ip6 dev br-ex | grep $ldap_ip6"
  }
}