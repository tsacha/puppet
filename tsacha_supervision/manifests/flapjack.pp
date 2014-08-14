class tsacha_supervision::flapjack {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  exec { "flapjack-gem":
    command => "gem install flapjack",
    unless => "gem list | grep flapjack",
    timeout => 1000
  }

  file { "/etc/flapjack":
    ensure => directory,
    owner => root,
    group => root,
    mode => 0755,
  } ->

  file { "/etc/flapjack/flapjack_config.yaml":
    ensure => present,
    owner => root,
    group => root,
    mode => 0664,
    content => template('tsacha_supervision/flapjack/flapjack_config.yaml.erb'),
  }


  file { "/etc/init.d/flapjack":
    ensure => present,
    owner => root,
    group => root,
    mode => 0755,
    content => template('tsacha_supervision/flapjack/init.erb'),
  }

  service { 'flapjack':
    ensure => running,
    require => [File['/etc/init.d/flapjack'],File['/etc/flapjack/flapjack_config.yaml']]
  }
}