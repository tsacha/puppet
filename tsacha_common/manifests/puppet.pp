class tsacha_common::puppet {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  $puppet = $hosts['kerbin']['physical']['fqdn']
  
  file { "/etc/puppet/puppet.conf":
    owner => root,
    group => root,
    mode => '0644',
    ensure => present,
    content => template('tsacha_common/puppet.conf.erb'),
  }

  file { "/etc/puppet/files":
    owner => puppet,
    group => puppet,
    mode => '0755',
    ensure => directory,
  }

  file { "/etc/puppet/etckeeper-commit-pre":
    owner => root,
    group => root,
    mode => '0755',
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-pre.erb'),
  }


  file { "/etc/puppet/etckeeper-commit-post":
    owner => root,
    group => root,
    mode => '0755',
    ensure => present,
    content => template('tsacha_common/etckeeper-commit-post.erb'),
  }

  exec { "enable-puppet":
    command => "systemctl enable puppet",
    unless => "systemctl is-enabled puppet",
  }

  service { 'puppet':
    ensure => running
  }
}
