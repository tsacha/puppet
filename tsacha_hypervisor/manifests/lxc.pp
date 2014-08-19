class tsacha_hypervisor::lxc {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { "lxc":
    ensure => installed
  }

  if($operatingsystem == "Debian") {

    $libvirt = 'libvirt-bin'
    $libvirtdev = 'libvirt-dev'
    $libvirtservice = 'libvirt-bin'

    package { 'cgroupfs-mount':
      ensure => installed
    }

    package { 'libvirt-dev':
      ensure => installed
    }
  
    package { 'make':
      ensure => installed
    }

    file { "/etc/default/grub":
      owner => root,
      group => root,
      mode => 0644,
      ensure => present,
      content => template('tsacha_hypervisor/grub.default.debian.erb'),
      notify => Exec['update-grub']
    }
  }

  if($operatingsystem == "CentOS") {

    $libvirt = 'libvirt'
    $libvirtdev = 'libvirt-devel'
    $libvirtservice = 'libvirtd'

    package { "libvirt-daemon-lxc":
      ensure => installed
    }

    exec { "edit-default-grub":
      command => "sed -Ei 's/^(GRUB_CMDLINE_LINUX=\".*)(\")/\1 cgroup_enable=memory\2/g' /etc/default/grub",
      unless => "grep 'cgroup_enable' /etc/default/grub",
      notify => Exec['update-grub']
    }

  }

  package { $libvirt:
    ensure => installed
  }

  package { $libvirtdev:
    ensure => installed
  }

  service { $libvirtservice:
    ensure => running
  }

  file { "/etc/libvirt/libvirtd.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/libvirtd.conf.erb'),
    require => Package[$libvirt],
    notify => Service[$libvirtd]
  }

  file { "/etc/libvirt/libvirt.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/libvirt.conf.erb'),
    require => Package[$libvirt],
    notify => Service[$libvirtd]
  }

  exec { 'ruby-libvirt':
    command => 'gem install --no-rdoc --no-ri ruby-libvirt',
    unless => "gem list ruby-libvirt | grep ruby-libvirt",
    require => Package[$libvirtdev]
  }

  package { 'debootstrap':
    ensure => installed
  }

  file { "/srv/generate_container.rb":
    owner => root,
    group => root,
    mode => 0755,
    ensure => present,
    content => template('tsacha_hypervisor/generate_container.rb.erb')
  }


  if($operatingsystem == "Debian") {
    exec { "update-grub":
      command => "update-grub2",
      refreshonly => true,
      notify => Exec['reboot-grub']
    }
  }

  if($operatingsystem == "CentOS") {
    exec { "update-grub":
      command => "grub2-mkconfig -o /boot/grub2/grub.cfg",
      refreshonly => true,
      notify => Exec['reboot-grub']
    }
  }

  exec { "reboot-grub":
    command => "shutdown -r now; sleep 10;",
    refreshonly => true
  }
}
