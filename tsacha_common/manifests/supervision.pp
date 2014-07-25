class tsacha_common::supervision {

  $sup_pubkey = hiera('sup_pubkey')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  group { "naemon":
    ensure => present
  } ->

  user { "naemon":
    ensure => present,
    shell => "/bin/bash",
    home => "/var/lib/naemon"
  }
    
  file { "/var/lib/naemon":
    ensure => directory,
    owner => naemon,
    group => naemon,
    mode => 0755,
    require => [User['naemon'],Group['naemon']]
  }

  file { "/var/lib/naemon/.ssh":
    ensure => directory,
    owner => naemon,
    group => naemon,
    mode => 0750,
    require => File['/var/lib/naemon']
  }

  file { "/var/lib/naemon/.ssh/authorized_keys":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0644,
    require => File['/var/lib/naemon/.ssh'],
  }

  file_line { 'sup-ssh':
    path => '/var/lib/naemon/.ssh/authorized_keys',
    line => file($sup_pubkey),
    require => File['/var/lib/naemon/.ssh/authorized_keys']
  }

  file { "/opt/monitoring-plugins.tar.gz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0640,
    source => "puppet:///modules/tsacha_supervision/nagios-plugins-1.5.tar.gz",
  } ->

  exec { "untar-plugins":
    command => "tar xvf monitoring-plugins.tar.gz",
    cwd => "/opt",
    unless => "stat nagios-plugins-1.5"
  } ->
  
  exec { "compile-plugins":
    command => "/opt/nagios-plugins-1.5/configure && make && make install",
    cwd => "/opt/nagios-plugins-1.5",
    timeout => 1000,
    require => Package['build-essential'],
    unless => "stat /usr/local/nagios/libexec/"
  }


  file { "/usr/local/nagios/libexec/check_puppet_agent.rb":
    ensure => present,
    owner => root,
    group => staff,
    mode => 0755,
    source => "puppet:///modules/tsacha_supervision/check_puppet_agent.rb",
    require => Exec['compile-plugins']
  }
}