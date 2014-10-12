class tsacha_web::webmail {

  $psql_password = hiera('psql::pwd')
  $webmail_password = hiera('psql::webmail_pwd')
  $des_key = hiera('web::des_key')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/apache2/sites-available/webmail.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => '0640',
    notify => File['/etc/apache2/sites-enabled/webmail.conf'],
    content => template('tsacha_web/webmail.erb'),
  }

  file { "/srv/web/webmail":
    ensure => directory,
    owner => apache,
    group => apache,
    mode => '0775',
  } ->

  file { "/srv/web/webmail/temp":
    ensure => directory,
    owner => apache,
    group => apache,
    mode => '0775',
  } ->

  file { "/etc/apache2/sites-enabled/webmail.conf":
    ensure => link,
    target => "/etc/apache2/sites-available/webmail.conf",
    require => [File["/srv/web/webmail"],File["/srv/certs/s.tremoureux.fr.crt"],File["/srv/certs/s.tremoureux.fr.key"],File["/srv/certs/gandi.pem"]],
    notify => Service['apache2']
  }

  file { "/srv/web/webmail/roundcube.tgz":
    ensure => present,
    source => "puppet:///modules/tsacha_web/roundcube.tar.gz",
    owner => apache,
    group => apache,
    mode => '0644',
  } ->


  exec { "extract-roundcube":
    command => "tar --strip-components=1 -xvf roundcube.tgz",
    cwd => "/srv/web/webmail",
    unless => "stat INSTALL"
  } ->

  file { "/srv/web/webmail/config/config.inc.php":
    ensure => present,
    owner => apache,
    group => apache,
    mode => '0660',
    content => template('tsacha_web/roundcube.conf.erb'),
  } ->

  file { "/srv/web/webmail/plugins/managesieve/config.inc.php":
    ensure => present,
    owner => apache,
    group => apache,
    mode => '0660',
    content => template('tsacha_web/managesieve.conf.erb'),
  } ->

  exec { "create-roundcube-dbuser":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE user roundcube WITH PASSWORD '$webmail_password'\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select usename from pg_catalog.pg_user where usename='roundcube'\" | grep rows",
  } ->

  exec { "create-roundcube-db":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE DATABASE roundcubemail\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select datname from pg_catalog.pg_database where datname='roundcubemail'\" | grep rows",
  } ->

  exec { "grant-roundcube-db":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"GRANT ALL PRIVILEGES ON DATABASE roundcubemail TO roundcube\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"SELECT datname,datacl FROM pg_database WHERE datname = 'roundcubemail' and('roundcube=CTc/postgres' = ANY(datacl));\" | grep rows",
  } -> 
  
  exec { "populate-roundcube-db":
    command => "psql -U roundcube -h psql.s.tremoureux.fr -d roundcubemail -f /srv/web/webmail/SQL/postgres.initial.sql",
    environment => ["PGPASSWORD=$webmail_password"],
    onlyif => "psql -U roundcube -h psql.s.tremoureux.fr -d roundcubemail -c \"select table_schema from information_schema.tables where table_schema='public';\"  | grep '(0 rows)'",
  }

  file { "/srv/web/mime.types":
    ensure => present,
    source => "puppet:///modules/tsacha_web/mime.types",
    owner => apache,
    group => apache,
    mode => '0644',
  }

}