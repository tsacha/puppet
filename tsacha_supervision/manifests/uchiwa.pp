class tsacha_supervision::uchiwa {

  Exec { path => [ "/opt/rabbitmq/sbin", "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  $hosts = hiera_hash('hosts')
  $sensu_passwd = hiera('rq::sensu')  

  exec { "clone-uchiwa":
    command => "git clone https://github.com/sensu/uchiwa.git",
    unless => "stat /opt/uchiwa",
    cwd => "/opt"
  }

  package { 'npm':
    ensure => installed,
  }

  exec { 'install-bower':
    command => "npm install -g bower",
    require => Package['npm'],
    onlyif => "npm ls -g bower | grep empty",
  }

  exec { 'install-deps':
    command => "npm install --production --unsafe-perm",
    cwd => '/opt/uchiwa',
    require => [Exec['install-bower'],Exec['clone-uchiwa']],
    unless => "stat /opt/uchiwa/node_modules",
  }

  file { "/opt/uchiwa/config.json":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    content => template('tsacha_supervision/uchiwa.config.js.erb'),
    require => Exec['clone-uchiwa']
  }

  file { "/etc/systemd/system/uchiwa.service":
    ensure => present,
    owner => root,
    group => root,
    mode => "0644",
    source => "puppet:///modules/tsacha_supervision/uchiwa.service",
    notify => Exec["refresh-units"]    
  }    

}
