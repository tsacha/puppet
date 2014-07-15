class tsacha_mail::postfix {

  $postfix_password = hiera('ldap::postfix_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  File {
    owner => root,
    group => postfix,
    mode => 644,
    ensure => present,
    require => Package['postfix'],
    notify => Service['postfix']
  }

  file { "/etc/postfix/main.cf":
    content => template('tsacha_mail/postfix/main.cf.erb'),
  }

  file { "/etc/postfix/master.cf":
    content => template('tsacha_mail/postfix/master.cf.erb'),
  }

  exec { "refresh-aliases":
    command => "postalias /etc/postfix/aliases",
    require => Package['postfix'],
    refreshonly => true
  }

  file { "/etc/postfix/aliases":
    source => "puppet:///modules/tsacha_mail/postfix/aliases",
    notify => Exec['refresh-aliases']
  }

  exec { "refresh-virtual":
    command => "postalias /etc/postfix/virtual",
    require => Package['postfix'],
    refreshonly => true
  }

  file { "/etc/postfix/virtual":
    source => "puppet:///modules/tsacha_mail/postfix/virtual",
    notify => Exec['refresh-virtual']
  }

  file { "/etc/postfix/ldap-virtual.cf":
    mode => 640,
    content => template('tsacha_mail/postfix/ldap-virtual.cf.erb'),
  }

  service { 'postfix':
    ensure => running,
  }

}