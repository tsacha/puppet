class tsacha_im::pkg {
  package { 'prosody':
    ensure => installed
  } ->

  user { "prosody":
    ensure => present,
    groups => sasl
  }

  package { 'ldap-utils':
    ensure => installed
  }

  package { 'postgresql-client':
    ensure => installed
  }

  package { 'lua-dbi-sqlite3':
    ensure => installed
  }

  package { 'lua-dbi-postgresql':
    ensure => installed
  }
  
  package { 'lua-zlib':
    ensure => installed
  }

  package { 'lua-ldap':
    ensure => installed
  }

  package { ['lua-cyrussasl','libsasl2-modules-ldap','libsasl2-2','libsasl2-modules','sasl2-bin']:
    ensure => installed
  }
}