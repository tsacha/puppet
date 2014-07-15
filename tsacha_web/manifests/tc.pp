class tsacha_web::tc {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/etc/apache2/sites-available/tc.conf":
      ensure => present,
      owner => root,
      group => root,
      mode => 640,
      notify => File['/etc/apache2/sites-enabled/tc.conf'],
      content => template('tsacha_web/tc.erb'),
    }

    file { "/etc/apache2/sites-enabled/tc.conf":
      ensure => link,
      target => "/etc/apache2/sites-available/tc.conf",
      notify => Service['apache2']
    }

    file { "/srv/web/tc":
      ensure => directory,
      owner => www-data,
      group => www-data,
      mode => 775
    }
}