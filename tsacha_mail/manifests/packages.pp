class tsacha_mail::packages {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  package { 'openldap-clients':
    ensure => installed
  }
  
  package { ['dovecot','dovecot-pigeonhole']:
    ensure => installed,
  }

  package { 'postfix':
    ensure => installed
  }

  package { 'spamassassin':
    ensure => installed,
    notify => Exec['spamassassin-update']
  }  
  
  package { 'opendkim':
    ensure => installed,
    require => Exec['repo_changed_update']
  }

  package { 'rsync':
    ensure => installed,
  }

}
