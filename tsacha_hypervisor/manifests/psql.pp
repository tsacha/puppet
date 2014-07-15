# psql.pp
#
# Psql container generation

class tsacha_hypervisor::psql {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::mail'] -> Class['tsacha_hypervisor::psql']

  $idhypervisor = hiera('containers::idhypervisor')
  $psql_cidr = hiera('containers::cidr')
  $psql_cidr6 = hiera('containers::cidr6')
  $psql_gateway = hiera('containers::gateway')
  $psql_gateway6 = hiera('containers::gateway6')
  $psql_puppet = hiera('containers::puppet')
  $psql_ip_puppet = hiera('containers::ip_puppet')
  $psql_ip6_puppet = hiera('containers::ip6_puppet')
  $psql_fqdn = hiera('containers::fqdn')
  $psql_hostname = hiera('psql::hostname')
  $psql_ip = hiera('psql::ip')
  $psql_ip6 = hiera('psql::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-psql-container":
    command => "ruby /srv/generate_container.rb --hostname $psql_hostname --domain $fqdn --ip $psql_ip --cidr $psql_cidr --gateway $psql_gateway --ip6 $psql_ip6 --cidr6 $psql_cidr6 --gateway6 $psql_gateway6 --dns 8.8.8.8 --puppet $psql_puppet --ippuppet $psql_ip_puppet --ip6puppet $psql_ip6_puppet --idhypervisor $idhypervisor --version stable",
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