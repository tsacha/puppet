class tsacha_supervision::config {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { ['/etc/naemon/conf.d/localhost.cfg', '/etc/naemon/conf.d/printer.cfg', '/etc/naemon/conf.d/switch.cfg', '/etc/naemon/conf.d/windows.cfg']:
    ensure => absent
  }

  file { "/etc/naemon/conf.d/commands.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/commands.cfg.erb'),
  }


  file { "/etc/naemon/conf.d/contacts.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/contacts.cfg.erb'),
  }

  file { "/etc/naemon/conf.d/timeperiods.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/timeperiods.cfg.erb'),
  }


  file { "/etc/naemon/conf.d/services.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/services.cfg.erb'),
  }

  file { "/etc/naemon/conf.d/hostdependency.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/hostdependency.cfg.erb'),
  }

  file { "/etc/naemon/conf.d/hostgroups.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/hostgroups.cfg.erb'),
  }


  file { "/etc/naemon/conf.d/templates/hosts.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/hosts.templates.cfg.erb'),
  }

  file { "/etc/naemon/conf.d/templates/services.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/services.templates.cfg.erb'),
  }

  file { "/etc/naemon/conf.d/templates/contacts.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/conf.d/contacts.templates.cfg.erb'),
  }

  file { "/etc/naemon/naemon.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/naemon.cfg.erb'),
  }

  file { "/etc/naemon/resource.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/resource.cfg.erb'),
  }

  file { "/etc/naemon/cgi.cfg":
    ensure => present,
    owner => naemon,
    group => naemon,
    mode => 0664,
    content => template('tsacha_supervision/cgi.cfg.erb'),
  }

  $hosts = hiera_hash('hosts')
  $hosts.each |$key,$value| {
    $value.each |$hostname,$conf| {
      $host_name = $conf['fqdn']
      $host_address = $conf['ip6']
      $type = $hostname

      file { "/etc/naemon/conf.d/${conf['fqdn']}.cfg":
        ensure => present,
        owner => naemon,
        group => naemon,
        mode => 0664,
        content => template('tsacha_supervision/conf.d/hosts.cfg.erb')
      }
    }
  }
}