class tsacha_hypervisor::lxc {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { "lxc":
    ensure => installed
  }

  package { "lxc-templates":
    ensure => installed
  }

  exec { "edit-default-grub":
    command => "sed -Ei 's/^(GRUB_CMDLINE_LINUX=\".*)(\")/\1 cgroup_enable=memory\2/g' /etc/default/grub",
    unless => "grep 'cgroup_enable' /etc/default/grub",
    notify => Exec['update-grub']
  }


  file { "/srv/generate_container.rb":
    owner => root,
    group => root,
    mode => '0755',
    ensure => present,
    content => template('tsacha_hypervisor/generate_container.rb.erb')
  }

  file { "/srv/ip-neigh":
    owner => root,
    group => root,
    mode => '0755',
    ensure => present,
    content => template('tsacha_hypervisor/ip-neigh.erb')
  }


  exec { "update-grub":
    command => "grub2-mkconfig -o /boot/grub2/grub.cfg",
    refreshonly => true,
    notify => Exec['reboot-grub']
  }

  exec { "reboot-grub":
    command => "shutdown -r now; sleep 10;",
    refreshonly => true,
#    subscribe => File['/etc/selinux/config']
  }
}
