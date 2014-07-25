class tsacha_im::certs {
  file { "/srv/certs":
    ensure => directory,
    owner => prosody,
    group => prosody,
    mode => 0550,
  }

  file { "/srv/certs/ldap.pem":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0444,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/gandi.pem",
  }


  file { "/srv/certs/gandi.pem":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0444,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/gandi.pem",
  }


  file { "/srv/certs/tremoureux.fr.crt":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0440,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/chain.tremoureux.fr.crt",
  }


  file { "/srv/certs/tremoureux.fr.key":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0400,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/tremoureux.fr.key",
  }

  file { "/srv/certs/s.tremoureux.fr.crt":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0440,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/chain.s.tremoureux.fr.crt",
  }


  file { "/srv/certs/s.tremoureux.fr.key":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0400,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.key",
  }

  file { "/srv/certs/glenn.pro.crt":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0440,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/chain.glenn.pro.crt",
  }


  file { "/srv/certs/glenn.pro.key":
    ensure => present,
    owner => prosody,
    group => prosody,
    mode => 0400,
    require => File['/srv/certs'],
    source => "puppet:///modules/tsacha_private/global/glenn.pro.key",
  }

}