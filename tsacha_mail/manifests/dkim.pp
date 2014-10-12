class tsacha_mail::dkim {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  service { 'opendkim':
    ensure => running
  }

  $dkimfolders = [
    "/etc/opendkim",
    "/etc/opendkim/keys",
    "/etc/opendkim/keys/glenn.pro",
    "/etc/opendkim/keys/glenn-s.eu",
    "/etc/opendkim/keys/sharne.eu",
    "/etc/opendkim/keys/terres-creuses.fr",
    "/etc/opendkim/keys/tremoureux.fr"
  ]

  file { $dkimfolders:
    owner   => opendkim,
    group   => opendkim,
    mode    => '0750',
    ensure  => directory,
    notify  => Service['opendkim']
  }

  $dkim_conf = [
    "keys/glenn.pro/default.private",
    "keys/glenn-s.eu/default.private",
    "keys/sharne.eu/default.private",
    "keys/terres-creuses.fr/default.private",
    "keys/tremoureux.fr/default.private",
    "keys/glenn.pro/default.txt",
    "keys/glenn-s.eu/default.txt",
    "keys/sharne.eu/default.txt",
    "keys/terres-creuses.fr/default.txt",
    "keys/tremoureux.fr/default.txt",
  ]

  File {
    ensure => present,
    owner => opendkim,
    group => opendkim,
    mode => '0640',
    notify => Service['opendkim']
  }
  
  file { "/etc/opendkim/SigningTable":
    content => template("tsacha_mail/dkim/SigningTable.erb")
  }

  file { "/etc/opendkim/TrustedHosts":
    content => template("tsacha_mail/dkim/TrustedHosts.erb")
  }

  file { "/etc/opendkim/KeyTable":
    content => template("tsacha_mail/dkim/KeyTable.erb")
  }

  file { "/etc/opendkim.conf":
    content => template("tsacha_mail/dkim/opendkim.conf.erb"),
    owner => root,
    group => root,
    mode => '0644'
  }
  
  $dkim_conf.each |$title| {
    file { "/etc/opendkim/${title}":
      source => "puppet:///modules/tsacha_private/dkim/${title}",
    }
  }

}
