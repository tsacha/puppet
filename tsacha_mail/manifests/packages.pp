class tsacha_mail::packages {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'ldap-utils':
    ensure => installed
  }
  
  package { 'dovecot-imapd':
    ensure => installed
  } ->

  package { ['dovecot-ldap', 'dovecot-lmtpd', 'dovecot-sieve', 'dovecot-managesieved']:
    ensure => installed,
  }

  package { 'postfix':
    ensure => installed
  }

  package { 'postfix-ldap':
    ensure => installed
  }

  package { 'spamassassin':
    ensure => installed,
    notify => Exec['spamassassin-update']
  }  
  
  package { 'opendkim':
    ensure => installed,
  }

  package { 'rsync':
    ensure => installed,
  }

}