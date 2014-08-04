# psql.pp
#
# Psql container generation

class tsacha_hypervisor::psql {
  include tsacha_hypervisor::network

  require tsacha_hypervisor::dns

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $psql_cidr = $hosts[$hostname]['physical']['cidr_private']
  $psql_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $psql_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $psql_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $psql_puppet = $hosts['kerbin']['physical']['fqdn']
  $psql_ip_puppet = $hosts['kerbin']['physical']['ip']
  $psql_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $psql_fqdn = $hosts[$hostname]['psql']['fqdn']
  $psql_ip = $hosts[$hostname]['psql']['ip']
  $psql_ip6 = $hosts[$hostname]['psql']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-psql-container":
    command => "ruby /srv/generate_container.rb --fqdn $psql_fqdn --ip $psql_ip --cidr $psql_cidr --gateway $psql_gateway --ip6 $psql_ip6 --cidr6 $psql_cidr6 --gateway6 $psql_gateway6 --dns 8.8.8.8 --puppet $psql_puppet --ippuppet $psql_ip_puppet --ip6puppet $psql_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep psql",
    timeout => 500
  } ->

  exec { "start-psql-container":
    command => "virsh start psql",
    unless => "virsh list | grep psql",
  }

  exec { "psql-neigh":
    command => "ip -6 neigh add proxy $psql_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $psql_ip6 dev br-ex | grep $psql_ip6"
  }
}