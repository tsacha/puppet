class tsacha_web::certs {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }


    group { 'apache':
      ensure => present
    }
    
    user { 'apache':
      ensure => present,
      shell => "/sbin/nologin",
      home => "/var/www",
      gid => 'apache',
      require => Group['apache']
    }

    file { "/srv/certs":
      ensure => directory,
      owner => apache,
      group => apache,
      mode => '0500',
      seltype =>'httpd_config_t',
      require => User['apache']
    }

    file { "/srv/certs/s.tremoureux.fr.crt":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.crt",
      seltype =>'httpd_config_t'      
    }    

    file { "/srv/certs/s.tremoureux.fr.key":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/s.tremoureux.fr.key",
      seltype =>'httpd_config_t'      
    }    

    file { "/srv/certs/tremoureux.fr.crt":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/tremoureux.fr.crt",
      seltype =>'httpd_config_t'      
    }    

    file { "/srv/certs/tremoureux.fr.key":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/tremoureux.fr.key",
      seltype =>'httpd_config_t'      
    }    

    file { "/srv/certs/gandi.pem":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/gandi.pem",
      seltype =>'httpd_config_t'      
    }    
    
    file { "/srv/certs/glenn.pro.crt":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/glenn.pro.crt",
      seltype =>'httpd_config_t'      
    }    

    file { "/srv/certs/glenn.pro.key":
      ensure => present,
      owner => apache,
      group => apache,
      mode => '0400',
      require => [File['/srv/certs'],User['apache']],
      source => "puppet:///modules/tsacha_private/global/glenn.pro.key",
      seltype =>'httpd_config_t'      
    }    
}
