# ldap.pp
#
# Ldap container generation

class tsacha_hypervisor::ldap {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::dns'] -> Class['tsacha_hypervisor::ldap']

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $ldap_cidr = $hosts[$hostname]['physical']['cidr_private']
  $ldap_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $ldap_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $ldap_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $ldap_puppet = $hosts['kerbin']['physical']['fqdn']
  $ldap_ip_puppet = $hosts['kerbin']['physical']['ip']
  $ldap_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $ldap_fqdn = $hosts[$hostname]['ldap']['fqdn']
  $ldap_ip = $hosts[$hostname]['ldap']['ip']
  $ldap_ip6 = $hosts[$hostname]['ldap']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-ldap-container":
    command => "ruby /srv/generate_container.rb --fqdn $ldap_fqdn --ip $ldap_ip --cidr $ldap_cidr --gateway $ldap_gateway --ip6 $ldap_ip6 --cidr6 $ldap_cidr6 --gateway6 $ldap_gateway6 --dns 8.8.8.8 --puppet $ldap_puppet --ippuppet $ldap_ip_puppet --ip6puppet $ldap_ip6_puppet --idhypervisor $idhypervisor --version stable",
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