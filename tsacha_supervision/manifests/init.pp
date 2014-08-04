class tsacha_supervision {
  class { 'tsacha_supervision::install': } ->
  class { 'tsacha_supervision::config': } ->
  class { 'tsacha_supervision::elk': } ->

  file { "/var/lib/naemon/.ssh/id_ecdsa":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0400,
    source => "puppet:///modules/tsacha_private/ssh/sup",
    require => File['/var/lib/naemon/.ssh']
  } ->

  file { "/var/lib/naemon/.ssh/id_ecdsa.pub":
    ensure => directory,
    owner => naemon,
    group => naemon,
    mode => 0640,
    source => "puppet:///modules/tsacha_private/ssh/sup.pub",
    require => File['/var/lib/naemon/.ssh']
  }

  service { 'naemon':
    ensure => running
  }

  service { 'thruk':
    ensure => running,
    require => File["/etc/apache2/conf-enabled/thruk_cookie_auth_vhost.conf"]
  }

}
