class tsacha_backup {

  $psql_password = hiera('psql::pwd')

  package { 'postgresql':
    ensure => installed
  }

  package { 'mariadb':
    ensure => installed
  }
  
  group { "backup":
    ensure => present
  }
  
  user { "backup":
    ensure => present,
    gid => "backup",
    home => "/srv/backup",
    require => Group["backup"]
  }

  file { "/srv/backup/.ssh":
    owner => "backup",
    group => "backup",
    mode => '0700',
    ensure => directory,
  }
  
  file { "/srv/backup/.ssh/id_ecdsa":
    owner => "backup",
    group => "backup",
    mode => '0600',
    ensure => present,
    source => "puppet:///modules/tsacha_private/ssh/backup-$hostname",
    require => File['/srv/backup/.ssh']
  }  

  file { "/srv/backup/.ssh/id_ecdsa.pub":
    owner => "backup",
    group => "backup",
    mode => '0644',
    ensure => present,
    source => "puppet:///modules/tsacha_private/ssh/backup-$hostname.pub",
    require => File['/srv/backup/.ssh']
  }  
  
  file { "/srv/backup":
    ensure => directory,
    owner => "backup",
    group => "backup",
    mode => "0770",
    require => User["backup"]
  }

  cron { "mails-jool":
    ensure => present,
    hour => 4,
    minute => 0,
    command => "rdiff-backup --remote-schema=\"ssh -o StrictHostKeyChecking=no -C \%s rdiff-backup --server\" root@mail-jool::/srv/mail /srv/backup/mail-jool --remove-older-than 1Y",
    user => "backup",
    require => File['/srv/backup'],
    environment => "PATH=/bin:/usr/bin:/usr/sbin"
  }

  cron { "web-jool":
    ensure => present,
    minute => 0,
    command => "rdiff-backup --remote-schema=\"ssh -o StrictHostKeyChecking=no -C \%s rdiff-backup --server\" root@web-jool::/srv/web /srv/backup/web-jool --remove-older-than 1W",
    user => "backup",
    require => File['/srv/backup'],
    environment => "PATH=/bin:/usr/bin:/usr/sbin"
  }

  cron { "im-jool-sql":
    ensure => present,
    environment => ["PGPASSWORD=$psql_password"],
    user => "backup",
    command => "pg_dump -U postgres -h psql-jool prosody -f /srv/backup/im-jool.sql",
    require => Package['postgresql']
  }

  
}
