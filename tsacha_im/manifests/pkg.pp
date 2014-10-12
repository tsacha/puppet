class tsacha_im::pkg {
  package { "prosody":
    ensure => installed
  }
  package { "lua-ldap":
    ensure => installed
  }
  package { "cyrus-sasl":
    ensure => installed
  }
  package { "cyrus-sasl-plain":
    ensure => installed
  }
  package { "cyrus-sasl-ldap":
    ensure => installed
  }
  package { "lua-cyrussasl":
    ensure => installed
  }  
  package { "openldap-clients":
    ensure => installed
  }
  package { "postgresql":
    ensure => installed
  }
}
