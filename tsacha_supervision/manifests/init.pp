class tsacha_supervision {
  class { 'tsacha_supervision::install': } ->

  file { "/var/lib/nagios/.ssh/id_ecdsa":
    ensure => present,
    owner => nagios,
    group => nagios,
    mode => 400,
    source => "puppet:///modules/tsacha_private/ssh/sup",
    require => File['/var/lib/nagios/.ssh']
  } ->

  file { "/var/lib/nagios/.ssh/id_ecdsa.pub":
    ensure => directory,
    owner => nagios,
    group => nagios,
    mode => 640,
    source => "puppet:///modules/tsacha_private/ssh/sup.pub",
    require => File['/var/lib/nagios/.ssh']
  }

}
