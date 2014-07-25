class tsacha_common::network {
  file { "/etc/resolv.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/resolv.conf.erb'),
  }
}  

