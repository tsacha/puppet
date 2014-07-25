class tsacha_supervision::install {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }


  $naemondeps = ["libapache2-mod-fcgid","xvfb","libfontconfig1","libjpeg8","libpng12-0","libmysqlclient18", "bsd-mailx"]

  file { "/opt/naemon.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-core.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-core_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-core-dbg.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-core-dbg_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-dev.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-dev_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-livestatus.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-livestatus_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-thruk.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-thruk_0.8.0_debian8_amd64.deb",
  }
		
  file { "/opt/naemon-thruk-libs.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-thruk-libs_0.8.0_debian8_amd64.deb",
  }

  file { "/opt/naemon-thruk-reporting.deb":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    source => "puppet:///modules/tsacha_supervision/naemon-thruk-reporting_0.8.0_debian8_amd64.deb",
  }

  package { $naemondeps:
    ensure => installed
  }

  package { 'naemon-core':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-core.deb",
    require => [File["/opt/naemon-core.deb"],Package[$naemondeps]],
    subscribe => File["/opt/naemon-core.deb"]
  }

  package { 'naemon':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon.deb",
    require => [File["/opt/naemon.deb"],Package['naemon-thruk-reporting']],
    subscribe => File["/opt/naemon.deb"],
    notify => Exec["restart-services"]
  }
  package { 'naemon-dev':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-dev.deb",
    require => [File["/opt/naemon-dev.deb"],Package['naemon-core']],
    subscribe => File["/opt/naemon-dev.deb"]
  }
  package { 'naemon-livestatus':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-livestatus.deb",
    require => [File["/opt/naemon-livestatus.deb"],Package['naemon-dev']],
    subscribe => File["/opt/naemon-livestatus.deb"]
  }
  package { 'naemon-thruk':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-thruk.deb",
    require => [File["/opt/naemon-thruk.deb"],Package['naemon-thruk-libs']],
    subscribe => File["/opt/naemon-thruk.deb"]
  }

  package { 'naemon-thruk-reporting':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-thruk-reporting.deb",
    require => [File["/opt/naemon-thruk.deb"],Package['naemon-thruk']],
    subscribe => File["/opt/naemon-thruk-reporting.deb"]
  }

  package { 'naemon-thruk-libs':
    ensure => installed,
    provider => dpkg,
    source => "/opt/naemon-thruk-libs.deb",
    require => [File["/opt/naemon-thruk-libs.deb"],Package['naemon-livestatus']],
    subscribe => File["/opt/naemon-thruk-libs.deb"]
  }

  exec { 'restart-services':
    command => "/etc/init.d/naemon restart && /etc/init.d/thruk restart",
    refreshonly => true
  }

  package { 'libnet-ldap-perl':
    ensure => installed
  }

  file { "/etc/apache2/conf-available/thruk_cookie_auth_vhost.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 0644,
    content => template('tsacha_supervision/thruk_apache.conf.erb'),
    require => Package['naemon-thruk']
  }

  file { "/etc/apache2/conf-enabled/thruk_cookie_auth_vhost.conf":
    ensure => link,
    target => "/etc/apache2/conf-available/thruk_cookie_auth_vhost.conf",
    require => File["/etc/apache2/conf-available/thruk_cookie_auth_vhost.conf"],
    notify => Service['apache2'],
  }


  file { "/opt/check-ldap":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0755,
    source => "puppet:///modules/tsacha_supervision/check_ldap",
  }

}