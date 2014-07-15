# mail.pp
#
# Mail container generation

class tsacha_hypervisor::mail {
  include tsacha_hypervisor::network

  Class['tsacha_hypervisor::ldap'] -> Class['tsacha_hypervisor::mail']

  $idhypervisor = hiera('containers::idhypervisor')
  $mail_cidr = hiera('containers::cidr')
  $mail_cidr6 = hiera('containers::cidr6')
  $mail_gateway = hiera('containers::gateway')
  $mail_gateway6 = hiera('containers::gateway6')
  $mail_puppet = hiera('containers::puppet')
  $mail_ip_puppet = hiera('containers::ip_puppet')
  $mail_ip6_puppet = hiera('containers::ip6_puppet')
  $mail_fqdn = hiera('containers::fqdn')
  $mail_hostname = hiera('mail::hostname')
  $mail_ip = hiera('mail::ip')
  $mail_ip6 = hiera('mail::ip6')

  Exec { path => [ "/srv", "/opt/libvirt/bin", "/opt/libvirt/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "generate-mail-container":
    command => "ruby /srv/generate_container.rb --hostname $mail_hostname --domain $fqdn --ip $mail_ip --cidr $mail_cidr --gateway $mail_gateway --ip6 $mail_ip6 --cidr6 $mail_cidr6 --gateway6 $mail_gateway6 --dns 8.8.8.8 --puppet $mail_puppet --ippuppet $mail_ip_puppet --ip6puppet $mail_ip6_puppet --idhypervisor $idhypervisor --version stable",
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