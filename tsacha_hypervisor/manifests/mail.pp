# mail.pp
#
# Mail container generation

class tsacha_hypervisor::mail {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::dns'] -> Class['tsacha_hypervisor::mail']

  $hosts = hiera_hash('hosts')

  $idhypervisor = $hosts[$hostname]['physical']['idhypervisor']
  $mail_cidr = $hosts[$hostname]['physical']['cidr_private']
  $mail_cidr6 = $hosts[$hostname]['physical']['cidr6']
  $mail_gateway = $hosts[$hostname]['physical']['ip_private_address']
  $mail_gateway6 = $hosts[$hostname]['physical']['gateway6']
  $mail_puppet = $hosts['kerbin']['physical']['fqdn']
  $mail_ip_puppet = $hosts['kerbin']['physical']['ip']
  $mail_ip6_puppet = $hosts['kerbin']['physical']['ip6']
  $mail_fqdn = $hosts[$hostname]['mail']['fqdn']
  $mail_ip = $hosts[$hostname]['mail']['ip']
  $mail_ip6 = $hosts[$hostname]['mail']['ip6']

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-mail-container":
    command => "ruby /srv/generate_container.rb --fqdn $mail_fqdn --ip $mail_ip --cidr $mail_cidr --gateway $mail_gateway --ip6 $mail_ip6 --cidr6 $mail_cidr6 --gateway6 $mail_gateway6 --dns 8.8.8.8 --puppet $mail_puppet --ippuppet $mail_ip_puppet --ip6puppet $mail_ip6_puppet --idhypervisor $idhypervisor --version stable",
    unless => "virsh list --all | grep mail",
    timeout => 500
  } ->

  exec { "start-mail-container":
    command => "virsh start mail",
    unless => "virsh list | grep mail",
  }

  exec { "mail-neigh":
    command => "ip -6 neigh add proxy $mail_ip6 dev br-ex",
    unless => "ip -6 neigh show proxy $mail_ip6 dev br-ex | grep $mail_ip6"
  }
}