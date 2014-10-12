class tsacha_im::ldap {

  $admin_password = hiera('ldap::admin_pwd')
  $ldap_im_password = hiera('ldap::prosody_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  file { "/etc/openldap/ldap.conf":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_ldap/ldap.conf.erb'),
  }

  file { "/opt/prosody.ldif":
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_im/prosody.ldif",
  }


  exec { "prosody-ldap":
    command => "ldapadd -H ldaps://ldap.s.tremoureux.fr -x -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' -f prosody.ldif",
    unless => "ldapsearch -H ldaps://ldap.s.tremoureux.fr/ -x -b cn=prosody,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: cn=prosody' && ldapsearch -H ldaps://ldap.s.tremoureux.fr/ -x -b ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$admin_password' | grep 'dn: ou=users'",
    cwd => "/opt",
    require => [File['/etc/openldap/ldap.conf'],File['/opt/prosody.ldif']]
  }
  exec { "change-password-prosody-ldap":
    command => "ldappasswd -H ldaps://ldap.s.tremoureux.fr/ -x -w \"$admin_password\" -D cn=admin,dc=ldap,dc=s,dc=tremoureux,dc=fr -s \"$ldap_im_password\" cn=prosody,dc=ldap,dc=s,dc=tremoureux,dc=fr",
    require => Exec['prosody-ldap'],
    unless => "ldapsearch -H ldaps://ldap.s.tremoureux.fr/ -x -b ou=users,dc=ldap,dc=s,dc=tremoureux,dc=fr -D cn=prosody,dc=ldap,dc=s,dc=tremoureux,dc=fr -w '$ldap_im_password'"
  }

  file { "/etc/saslauthd.conf":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_im/saslauthd.conf.erb'),
    notify => Service['saslauthd']
  }

  file { "/etc/sysconfig/saslauthd":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_im/default_saslauthd.erb'),
    notify => Service['saslauthd']
  }

  file { "/etc/sasl2/prosody.conf":
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_im/sasl_prosody.conf.erb'),
    notify => Service['saslauthd']
  }


}
