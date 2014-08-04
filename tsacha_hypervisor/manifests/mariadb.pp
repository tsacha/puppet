# mariadb.pp
#
# Mariadb container generation

class tsacha_hypervisor::mariadb {
  include tsacha_hypervisor::network

  require tsacha_hypervisor::dns

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $mariadb_cidr = $hosts[$hostname]['physical']['cidr_private']
  $mariadb_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $mariadb_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $mariadb_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $mariadb_puppet = $hosts['kerbin']['physical']['fqdn']
  $mariadb_ip_puppet = $hosts['kerbin']['physical']['ip']
  $mariadb_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $mariadb_fqdn = $hosts[$hostname]['mariadb']['fqdn']
  $mariadb_ip = $hosts[$hostname]['mariadb']['ip']
  $mariadb_ip6 = $hosts[$hostname]['mariadb']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-mariadb-container":
    command => "ruby /srv/generate_container.rb --fqdn $mariadb_fqdn --ip $mariadb_ip --cidr $mariadb_cidr --gateway $mariadb_gateway --ip6 $mariadb_ip6 --cidr6 $mariadb_cidr6 --gateway6 $mariadb_gateway6 --dns 8.8.8.8 --puppet $mariadb_puppet --ippuppet $mariadb_ip_puppet --ip6puppet $mariadb_ip6_puppet --idhypervisor $idhypervisor --version testing",
    unless => "virsh list --all | grep mariadb",
    timeout => 500
  } ->

  exec { "start-mariadb-container":
    command => "virsh start mariadb",
    unless => "virsh list | grep mariadb",
  }

  exec { "mariadb-neigh":
    command => "ip -6 neigh add proxy $mariadb_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $mariadb_ip6 dev br-ex | grep $mariadb_ip6"
  }
}