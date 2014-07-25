class tsacha_web::autoconfig {

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

    file { "/etc/apache2/sites-available/autoconfig.conf":
      ensure => present,
      owner => root,
      group => root,
      mode => 0640,
      notify => File['/etc/apache2/sites-enabled/autoconfig.conf'],
      content => template('tsacha_web/autoconfig.erb'),
    }

    file { "/etc/apache2/sites-enabled/autoconfig.conf":
      ensure => link,
      target => "/etc/apache2/sites-available/autoconfig.conf",
      notify => Service['apache2']
    }

    file { "/srv/web/autoconfig":
      ensure => directory,
      owner => www-data,
      group => www-data,
      mode => 0775
    } ->

    file { "/srv/web/autoconfig/mail":
      ensure => directory,
      owner => www-data,
      group => www-data,
      mode => 0775
    } ->

    file { "/srv/web/autoconfig/mail/config-v1.1.xml":
      ensure => present,
      owner => www-data,
      group => www-data,
      mode => 0644,
      source => "puppet:///modules/tsacha_web/config-v1.1.xml"
    }


}