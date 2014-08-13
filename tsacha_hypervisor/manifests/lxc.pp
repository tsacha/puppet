class tsacha_hypervisor::lxc {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { "lxc":
    ensure => installed
  }
  package { "libvirt-bin":
    ensure => installed
  }

  package { 'cgroupfs-mount':
    ensure => installed
  }
 
  service { "libvirt-bin":
    ensure => running
  }

  file { "/etc/libvirt/libvirtd.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/libvirtd.conf.erb'),
    require => Package["libvirt-bin"],
    notify => Service['libvirt-bin']
  }

  file { "/etc/libvirt/libvirt.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/libvirt.conf.erb'),
    require => Package["libvirt-bin"],
    notify => Service['libvirt-bin']
  }

  package { 'libvirt-dev':
    ensure => installed
  }

  package { 'make':
    ensure => installed
  }

  exec { 'ruby-libvirt':
    command => 'gem install --no-rdoc --no-ri ruby-libvirt',
    unless => "gem list ruby-libvirt | grep ruby-libvirt",
    require => [Package['libvirt-dev'],Package['make']]
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

  file { "/etc/default/grub":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_hypervisor/grub.default.erb'),
  } ~>

  exec { "update-grub":
    command => "update-grub2",
    refreshonly => true,
  } ~>

  exec { "reboot-grub":
    command => "shutdown -r now; sleep 10;",
    refreshonly => true
  }
}


