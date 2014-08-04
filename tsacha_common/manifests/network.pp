class tsacha_common::network {
  file { "/etc/resolv.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/resolv.conf.erb'),
  }

  $hosts = hiera_hash('hosts')

  file { "/etc/hosts":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/hosts.erb'),
  }

}
