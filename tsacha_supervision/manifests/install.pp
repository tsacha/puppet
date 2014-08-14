class tsacha_supervision::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/opt/redis.tgz":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/redis-2.8.13.tar.gz",
  } ->

  exec { "extract-redis":
    command => "tar xvf /opt/redis.tgz",
    cwd => "/opt",
    unless => "stat /opt/redis-2.8.13"
  } ~>

  exec { "install-redis":
    command => "make && make install",
    cwd => "/opt/redis-2.8.13/",
    require => Exec['extract-redis'],
    refreshonly => true
  }

  group { 'redis':
    ensure => present,
  } ->

  user { 'redis':
    ensure => present,
    gid => "redis",
    home => "/var/lib",
    shell => "/bin/false"
  }

  file { '/etc/redis':
    ensure => directory,
    mode => 0755
  }

  file { '/var/log/redis':
    ensure => directory,
    mode => 0755,
    owner => redis,
    group => redis,
    require => User['redis']
  }

  file { '/var/lib/redis':
    ensure => directory,
    mode => 0755,
    owner => redis,
    group => redis,
    require => User['redis']
  }

  $redis_ports = [6379,6380]

  $redis_ports.each |$value| {
    file { "/etc/init.d/redis-$value":
      ensure => present,
      mode => 0755,
      owner => root,
      group => root,
      content => template('tsacha_supervision/redis/init.erb'),
    } ->

    file { "/etc/redis/$value.conf":
      ensure => present,
      mode => 0644,
      owner => redis,
      group => redis,
      content => template('tsacha_supervision/redis/conf.erb'),
      require => File['/etc/redis']
    } ->

    file { "/var/lib/redis/$value":
      ensure => directory,
      mode => 0644,
      owner => redis,
      group => redis,
      require => File['/var/lib/redis']
    }
  }

  package { 'rabbitmq-server':
    ensure => installed
  }

}