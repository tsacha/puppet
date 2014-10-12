class tsacha_ldap::install {

  $ldap_password = hiera('ldap::pwd')
  $ldap_password_hash = hiera('ldap::pwd_hash')
  $admin_password = hiera('ldap::admin_pwd')
  $postfix_password = hiera('ldap::postfix_pwd')
  $dovecot_password = hiera('ldap::dovecot_pwd')
  $prosody_password = hiera('ldap::prosody_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  package { 'openldap-servers':
    ensure => installed
  }

  package { 'openldap-clients':
    ensure => installed
  }

  file { "/srv/certs":
    ensure => directory,
    owner => ldap,
    group => ldap,
    mode => '0500',
    require => Package['openldap-servers']
  }

  file { "/srv/certs/ldap.crt":
    ensure => present,
    owner => ldap,
    group => ldap,
    mode => '0400',
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.crt",
    notify => Service['slapd']
  }

  file { "/srv/certs/ldap.key":
    ensure => present,
    owner => ldap,
    group => ldap,
    mode => '0400',
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.key",
    notify => Service['slapd']
  }

  file { "/srv/certs/ldap.pem":
    ensure => present,
    owner => ldap,
    group => ldap,
    mode => '0400',
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/gandi.pem",
    notify => Service['slapd']
  }

  file { "/opt/config.ldif":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/config.ldif.erb'),
  }

  file { "/opt/create-db.sh":
    owner => root,
    group => root,
    mode => '0755',
    content => template('tsacha_ldap/create-db.sh.erb'),
  }

  file { "/opt/db.ldif":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/db.ldif.erb'),
  }

  file { "/opt/extend.ldif":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/extend.ldif.erb'),
  }


  file { "/opt/pass-db.ldif":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/pass-db.ldif.erb'),
  }

  file { "/etc/openldap/ldap.conf":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/ldap.conf.erb'),
    notify => Service['slapd']
  }

  file { "/etc/sysconfig/slapd":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/slapd.default.erb'),
    notify => Service['slapd']
  }

  service { 'slapd':
    ensure => running,
    require => Package['openldap-servers']
  }

  exec { 'change-db':
    command => "ldapmodify -Y EXTERNAL -H ldapi:/// -f config.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b olcDatabase={2}hdb,cn=config | grep 'olcSuffix: dc=ldap,dc=s,dc=tremoureux,dc=fr'",
    cwd => "/opt",
    subscribe => File['/opt/config.ldif'],
    require => [File['/opt/config.ldif'],File['/etc/openldap/ldap.conf'],File['/srv/certs/ldap.pem'],File['/srv/certs/ldap.pem'],Service['slapd'],File['/etc/sysconfig/slapd']]
  } ->

  exec { 'pass-db':
    command => "ldapmodify -Y EXTERNAL -H ldapi:/// -f pass-db.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b olcDatabase={2}hdb,cn=config | grep 'olcRootPW: $ldap_password_hash'",
    cwd => "/opt",
    require => File['/opt/pass-db.ldif']
  } ->

  exec { 'cosine':
    command => "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn={1}cosine,cn=schema,cn=config",
  } ->

  exec { 'nis':
    command => "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn={2}nis,cn=schema,cn=config",
  } ->

  exec { 'inetorgperson':
    command => "ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn={3}inetorgperson,cn=schema,cn=config",
  } ->

  exec { 'extend-db':
    command => "ldapmodify -Y EXTERNAL -H ldapi:/// -f extend.ldif",
    unless => "ldapsearch -LLL -Y EXTERNAL -H ldapi:/// -b cn=schema,cn=config | grep mailAlias",
    cwd => "/opt",
    require => File['/opt/extend.ldif']
  } ->

  exec { 'create-db':
    command => "bash create-db.sh '$ldap_password' '$admin_password'",
    cwd => "/opt",
    unless => "ldapsearch -H ldap://$fqdn/ -x -w '$admin_password' -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -b dc=ldap,dc=s,dc=tremoureux,dc=fr | grep 'dn: cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr'",
  }
}
