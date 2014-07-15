class tsacha_glenn::drupal {

  $psql_password = hiera('psql::pwd')
  $drupal_password = hiera('glenn::drupal_pwd')

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

  file { "/etc/apache2/sites-available/drupal.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    notify => File['/etc/apache2/sites-enabled/drupal.conf'],
    content => template('tsacha_glenn/drupal.erb'),
  }

  file { "/etc/apache2/sites-enabled/drupal.conf":
    ensure => link,
    target => "/etc/apache2/sites-available/drupal.conf",
    notify => Service['apache2']
  }

  file { "/srv/web/drupal":
    ensure => directory,
    owner => www-data,
    group => www-data,
    mode => 755,
    require => File['/srv/web']
  }

  file { "/opt/drupal.tar.gz":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    source => "puppet:///modules/tsacha_glenn/drupal-7.latest.tar.gz",
  }

  exec { "create-drupal-dbuser":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE user drupal WITH PASSWORD '$drupal_password'\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select usename from pg_catalog.pg_user where usename='drupal'\" | grep rows",
  } ->

  exec { "create-drupal-db":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE DATABASE drupal WITH ENCODING 'UTF8' TEMPLATE template0\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select datname from pg_catalog.pg_database where datname='drupal'\" | grep rows",
  } ->

  exec { "grant-drupal-db":
    command => "psql -U postgres -h psql.s.tremoureux.fr -c \"GRANT ALL PRIVILEGES ON DATABASE drupal TO drupal\"",
    environment => ["PGPASSWORD=$psql_password"],
    onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"SELECT datname,datacl FROM pg_database WHERE datname = 'drupal' and('drupal=CTc/postgres' = ANY(datacl));\" | grep rows",
  }


}