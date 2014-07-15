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

  package { 'apt-file':
    ensure => installed
  }

  package { 'build-essential':
    ensure => installed
  }

}
