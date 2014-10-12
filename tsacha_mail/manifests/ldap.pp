class tsacha_mail::ldap {

  $hosts = hiera_hash('hosts')
  $domain_split = split($domain, '[.]')
  $hypervisor = $domain_split[0]

  $ldap_password = hiera('ldap::pwd')
  $ldap_password_hash = hiera('ldap::pwd_hash')
  $admin_password = hiera('ldap::admin_pwd')
  $postfix_password = hiera('ldap::postfix_pwd')
  $dovecot_password = hiera('ldap::dovecot_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  file { "/etc/openldap/ldap.conf":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/ldap.conf.erb'),
  }

  file { "/opt/dovecot.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_mail/dovecot/dovecot.ldif",
  }

  exec { "dovecot-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f dovecot.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b cn=dovecot,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: cn=dovecot' && ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: ou=users'",
    cwd => "/opt",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/dovecot.ldif']]
  }
  exec { "change-password-dovecot-ldap":
    command => "ldappasswd -H ldap://ldap.$hypervisor.trs.io/ -x -w \"$admin_password\" -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -s \"$dovecot_password\" cn=dovecot,dc=ldap,dc=s,dc=tremoureux,dc=fr",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=dovecot,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$dovecot_password'",
    require => Exec['dovecot-ldap']
  }

  file { "/opt/postfix.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_mail/postfix/postfix.ldif",
  }

  exec { "postfix-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f postfix.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b cn=postfix,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: cn=postfix'",
    cwd => "/opt",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/postfix.ldif']]
  }

  exec { "change-password-postfix-ldap":
    command => "ldappasswd -H ldap://ldap.$hypervisor.trs.io/ -x -w \"$admin_password\" -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -s \"$postfix_password\" cn=postfix,dc=ldap,dc=s,dc=tremoureux,dc=fr",
    require => Exec['postfix-ldap'],
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=postfix,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$postfix_password'"
  }


  file { "/opt/sacha.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_private/mail/sacha.ldif",
  }

  exec { "sacha-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f sacha.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b uid=sacha,ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: uid=sacha,ou=users'",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/sacha.ldif'],Exec['dovecot-ldap']],
    cwd => "/opt"
  }

  file { "/opt/glenn.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_private/mail/glenn.ldif",
  }

  exec { "glenn-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f glenn.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b uid=glenn,ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: uid=glenn,ou=users'",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/glenn.ldif'],Exec['dovecot-ldap']],
    cwd => "/opt"
  }

  file { "/opt/didier.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_private/mail/didier.ldif",
  }

  exec { "didier-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f didier.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b uid=didier,ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: uid=didier,ou=users'",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/didier.ldif'],Exec['dovecot-ldap']],
    cwd => "/opt"
  }

  file { "/opt/pascale.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_private/mail/pascale.ldif",
  }

  exec { "pascale-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f pascale.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b uid=pascale,ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: uid=pascale,ou=users'",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/pascale.ldif'],Exec['dovecot-ldap']],
    cwd => "/opt"
  }

  file { "/opt/ham.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_private/mail/ham.ldif",
  }

  exec { "ham-ldap":
    command => "ldapadd -H ldap://ldap.$hypervisor.trs.io -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f ham.ldif",
    unless => "ldapsearch -H ldap://ldap.$hypervisor.trs.io/ -x -b uid=ham,ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: uid=ham,ou=users'",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/ham.ldif'],Exec['dovecot-ldap']],
    cwd => "/opt"
  }

}
