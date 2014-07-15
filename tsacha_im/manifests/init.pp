class tsacha_im {
  class { 'tsacha_im::pkg': } ->
  class { 'tsacha_im::certs': } ->
  class { 'tsacha_im::ldap': } ->
  class { 'tsacha_im::psql': } ->
  class { 'tsacha_im::install': } ->

  service { 'prosody':
    ensure => running,
    hasstatus => false
  }
  service { 'saslauthd':
    ensure => running,
  }
}