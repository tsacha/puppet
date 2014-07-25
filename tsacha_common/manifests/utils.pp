class tsacha_common::utils {
  if($lsbdistcodename == "wheezy") {
    package { 'emacs23-nox':
      ensure => installed
    }
  }
  if($lsbdistcodename == "jessie") {
    package { 'emacs24-nox':
      ensure => installed
    }
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
    mode => 0400,
    ensure => present,
    content => template('tsacha_common/sudo.sup.erb'),    
  }

  package { 'apt-file':
    ensure => installed
  }

  package { 'build-essential':
    ensure => installed
  }

  package { 'git-core':
    ensure => installed
  }

}
