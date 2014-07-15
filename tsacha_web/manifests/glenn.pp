class tsacha_web::glenn {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/etc/apache2/sites-available/glenn.conf":
      ensure => present,
      owner => root,
      group => root,
      mode => 640,
      notify => File['/etc/apache2/sites-enabled/glenn.conf'],
      content => template('tsacha_web/glenn.erb'),
    }

    file { "/etc/apache2/sites-enabled/glenn.conf":
      ensure => link,
      target => "/etc/apache2/sites-available/glenn.conf",
      notify => Service['apache2']
    }

    file { "/srv/web/glenn":
      ensure => directory,
      owner => www-data,
      group => www-data,
      mode => 775
    }

}