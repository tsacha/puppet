class tsacha_common::utils {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

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
  if($operatingsystem == "CentOS") {
    package { 'emacs-nox':
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

  if($operatingsystem == "Debian") {
    package { 'apt-file':
      ensure => installed
    }

    package { 'w3m':
      ensure => installed
    }
  
    package { 'build-essential':
      ensure => installed
    }
  
    package { 'ruby-dev':
      ensure => installed
    }
  
    package { 'libssl-dev':
      ensure => installed
    }
  
    package { 'git-core':
      ensure => installed
    }
  
    package { 'dsh':
      ensure => installed
    }
  
    package { 'htop':
      ensure => installed 
    }
  
    $hosts = hiera_hash('hosts')
  
    file { '/etc/dsh/group/trs':
      owner => root,
      group => root,
      mode => 0644,
      ensure => present,
      content => template('tsacha_common/clusters.erb'),
      require => Package['dsh']
    }  
  }

  if($operatingsystem == "CentOS") {
    

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

  }

}
