# provisioning.pp
#
# Provisioning container

class tsacha_hypervisor::provisioning {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { 'provisioning-dns':
    command => "ssh -o StrictHostKeyChecking=no $dns_ip -C 'puppet agent -t'",
    returns => 2,
    timeout => 1200,
    unless => "ssh -o StrictHostKeyChecking=no $dns_ip -C 'cat /etc/default/puppet | grep START=yes'",
  }
}