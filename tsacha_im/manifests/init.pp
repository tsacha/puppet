class tsacha_im {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  class { 'tsacha_im::pkg': } ->
  class { 'tsacha_im::certs': } ->
  class { 'tsacha_im::ldap': } ->
  class { 'tsacha_im::psql': } ->
  class { 'tsacha_im::install': } ->

  service { 'prosody':
    ensure => running,
  } ->
  service { 'saslauthd':
    ensure => running,
  } ->

  exec { 'enable-prosody':
    command => "systemctl enable prosody",
    unless => "systemctl is-enabled prosody",
  } ->
  exec { 'enable-saslauthd':
    command => "systemctl enable saslauthd",
    unless => "systemctl is-enabled saslauthd",
  }
  
}
