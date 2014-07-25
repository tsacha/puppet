class tsacha_common::puppet {
  $hosts = hiera_hash('hosts')
  $puppet = $hosts['kerbin']['physical']['fqdn']

  file { "/etc/puppet/puppet.conf":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/puppet.conf.erb'),
  }

  file { "/etc/default/puppet":
    owner => root,
    group => root,
    mode => 0644,
    ensure => present,
    content => template('tsacha_common/puppet.default.erb'),
  }

  file { "/etc/puppet/etckeeper-commit-pre":
    owner => root,
    group => root,
    mode => 0755,
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-pre.erb'),
  }


  file { "/etc/puppet/etckeeper-commit-post":
    owner => root,
    group => root,
    mode => 0755,
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-post.erb'),
  }

  service { 'puppet':
    ensure => running
  }
}
