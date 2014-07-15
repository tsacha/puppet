class tsacha_common::supervision {

  $sup_pubkey = hiera('common::sup_pubkey')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  group { "nagios":
    ensure => present
  } ->

  user { "nagios":
    ensure => present,
    shell => "/bin/bash",
    home => "/var/lib/nagios"
  }
    
  file { "/var/lib/nagios":
    ensure => directory,
    owner => nagios,
    group => nagios,
    mode => 755,
    require => [User['nagios'],Group['nagios']]
  }

  file { "/var/lib/nagios/.ssh":
    ensure => directory,
    owner => nagios,
    group => nagios,
    mode => 750,
    require => File['/var/lib/nagios']
  }

  file { "/var/lib/nagios/.ssh/authorized_keys":
    ensure => present,
    owner => nagios,
    group => nagios,
    mode => 644,
    require => File['/var/lib/nagios/.ssh'],
  }

  file_line { 'sup-ssh':
    path => '/var/lib/nagios/.ssh/authorized_keys',
    line => "no-port-forwarding,no-agent-forwarding,no-X11-forwarding,no-pty $sup_pubkey",
    require => File['/var/lib/nagios/.ssh/authorized_keys']
  }

  file { "/opt/monitoring-plugins.tar.gz":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    source => "puppet:///modules/tsacha_supervision/nagios-plugins-1.5.tar.gz",
  } ->

  exec { "untar-plugins":
    command => "tar xvf monitoring-plugins.tar.gz",
    cwd => "/opt",
    unless => "stat nagios-plugins-1.5"
  } ->
  
  exec { "compile-plugins":
    command => "bash configure && make && make install",
    cwd => "/opt/nagios-plugins-1.5",
    timeout => 1000,
    require => Package['build-essential'],
    unless => "stat /usr/local/nagios/libexec/"
  }

}