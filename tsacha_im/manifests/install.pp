class tsacha_im::install {

  $im_password = hiera('psql::im_pwd')
  $ldap_im_password = hiera("ldap::prosody_pwd")

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/prosody/prosody.cfg.lua":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    notify => Service['prosody'],
    content => template('tsacha_im/prosody.cfg.lua.erb'),
  }
    
  file { "/opt/prosody-modules.tar":
    ensure => present,
    owner => root,
    group => root,
    mode => '0755',
    source => "puppet:///modules/tsacha_im/prosody-modules.tar",
  } ->
  exec { "untar-modules":
    command => "tar xvf prosody-modules.tar",
    cwd => "/opt",
    unless => "stat /opt/prosody-modules"
  }

  file { "/usr/lib64/prosody/modules/mod_remote_roster.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_remote_roster/mod_remote_roster.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/mod_auth_ldap.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_auth_ldap/mod_auth_ldap.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/mod_storage_ldap.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_storage_ldap/mod_storage_ldap.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/ldap/":
    ensure => directory,
    owner => root,
    group => root,
    mode => '0755',
  } ->

  file { "/usr/lib64/prosody/modules/ldap/vcard.lib.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_storage_ldap/ldap/vcard.lib.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/ldap.lib.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_lib_ldap/ldap.lib.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }  

  file { "/usr/lib64/prosody/modules/mod_watchuntrusted.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_watchuntrusted/mod_watchuntrusted.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/mod_carbons.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_carbons/mod_carbons.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/mod_checkcerts.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_checkcerts/mod_checkcerts.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

  file { "/usr/lib64/prosody/modules/mod_smacks.lua":
    ensure => link,
    target => "/opt/prosody-modules/mod_smacks/mod_smacks.lua",
    require => Exec["untar-modules"],
    notify => Service["prosody"]
  }

}
