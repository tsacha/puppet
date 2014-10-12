class tsacha_mail::dovecot {

  $dovecot_password = hiera('ldap::dovecot_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  service { 'dovecot':
    ensure => running
  }

  group { 'vmail':
    ensure => present,
    gid => 5000
  }

  user { 'vmail':
     home => '/srv/mail',
     shell => '/bin/false',
     uid => '5000',
     gid => '5000',
     ensure => 'present',
     require => Group ['vmail']
  }

  file { "/srv/mail":
    ensure => directory,
    owner => vmail,
    group => vmail,
    mode => '0660',
    require => User['vmail']
  }

  file { "/srv/certs":
    ensure => directory,
    owner => dovecot,
    group => mail,
    mode => '0550',
  }

  file { "/srv/certs/mail.crt":
    ensure => present,
    owner => dovecot,
    group => mail,
    mode => '0440',
    require => [File['/srv/certs'],Package['dovecot']],
    source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.crt",
  }    

  file { "/srv/certs/mail.key":
    ensure => present,
    owner => dovecot,
    group => mail,
    mode => '0440',
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.key",
  }    

  file { "/srv/certs/mail.pem":
    ensure => present,
    owner => dovecot,
    group => mail,
    mode => '0440',
    require => [File['/srv/certs'],Package['dovecot']],
    source => "puppet:///modules/tsacha_private/global/gandi.pem",
  }     

  file { "/srv/certs/ldap.pem":
    ensure => present,
    owner => dovecot,
    group => mail,
    mode => '0440',
    require => [File['/srv/certs'],Package['dovecot']],
    source => "puppet:///modules/tsacha_private/global/gandi.pem",
  }     

  $dovecot_conf = [
    "dovecot.conf",
    "dovecot-ldap.conf.ext",
    "conf.d/10-auth.conf",
    "conf.d/10-director.conf",
    "conf.d/10-logging.conf",
    "conf.d/10-mail.conf",
    "conf.d/10-master.conf",
    "conf.d/10-ssl.conf",
    "conf.d/10-tcpwrapper.conf",
    "conf.d/15-lda.conf",
    "conf.d/15-mailboxes.conf",
    "conf.d/20-imap.conf",
    "conf.d/20-lmtp.conf",
    "conf.d/20-managesieve.conf",
    "conf.d/90-acl.conf",
    "conf.d/90-plugin.conf",
    "conf.d/90-quota.conf",
    "conf.d/90-sieve.conf",
    "conf.d/auth-ldap.conf.ext"
  ]

  File {
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    require => Package['dovecot'],
    notify => Service['dovecot']
  }


  $dovecot_conf.each |$title| {
    file { "/etc/dovecot/${title}":
      content => template("tsacha_mail/dovecot/${title}.erb")
    }
  }

  file { "/srv/mail/default.sieve":
    ensure => present,
    owner => vmail,
    group => vmail,
    mode => '0644'
  }


  file { "/srv/mail/head.sieve":
    ensure => present,
    owner => vmail,
    group => vmail,
    mode => '0644',
    content => template("tsacha_mail/dovecot/head.sieve.erb")
  }

}
