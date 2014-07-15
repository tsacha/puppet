class tsacha_web::certs {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/srv/certs":
      ensure => directory,
      owner => www-data,
      group => www-data,
      mode => 500,
    }

    file { "/srv/certs/s.tremoureux.fr.crt":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.crt",
    }    

    file { "/srv/certs/s.tremoureux.fr.key":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.key",
    }    

    file { "/srv/certs/tremoureux.fr.crt":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/tremoureux.fr.crt",
    }    

    file { "/srv/certs/tremoureux.fr.key":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/tremoureux.fr.key",
    }    

    file { "/srv/certs/gandi.pem":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/gandi.pem",
    }    
    
    file { "/srv/certs/glenn.pro.crt":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/glenn.pro.crt",
    }    

    file { "/srv/certs/glenn.pro.key":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 400,
      require => File['/srv/certs'],
      source => "puppet:///modules/tsacha_private/global/glenn.pro.key",
    }    
}