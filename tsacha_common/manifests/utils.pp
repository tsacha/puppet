class tsacha_common::utils {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'bridge-utils':
    ensure => installed
  }

  package { 'emacs-nox':
    ensure => installed
  }

  package { 'tmux':
    ensure => installed
  }

  package { 'sudo':
    ensure => installed
  } ->

  file { '/etc/sudoers.d/sup':
    owner => root,
    group => root,
    mode => '0400',
    ensure => present,
    content => template('tsacha_common/sudo.sup.erb'),    
  }

  exec { "development-tools":
    command => "yum groupinstall -y 'Development Tools'",
    unless => "yum group list installed | grep 'Development Tools'"
  }

  package { "ruby-devel":
    ensure => installed
  }

  package { "openssl-devel":
    ensure => installed
  }

  package { "git":
    ensure => installed
  }

  package { "htop":
    ensure => installed
  }

  package { "tcpdump":
    ensure => installed
  }

  package { "yum-utils":
    ensure => installed
  }

  package { 'rdiff-backup':
    ensure => installed
  }

  package { 'bind-utils':
    ensure => installed
  }

  exec { 'refresh-units':
    command => "systemctl daemon-reload",
    refreshonly => true,
  }

}
