class tsacha_common::puppet {
  $puppet = hiera('containers::puppet')

  file { "/etc/puppet/puppet.conf":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_common/puppet.conf.erb'),
  }

  file { "/etc/default/puppet":
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_common/puppet.default.erb'),
  }

  file { "/etc/puppet/etckeeper-commit-pre":
    owner => root,
    group => root,
    mode => 755,
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-pre.erb'),
  }


  file { "/etc/puppet/etckeeper-commit-post":
    owner => root,
    group => root,
    mode => 755,
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-post.erb'),
  }
}
