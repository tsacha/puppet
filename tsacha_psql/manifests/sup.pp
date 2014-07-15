class tsacha_psql::sup {

    $psql_password = hiera('psql::pwd')

    Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

    exec { "create-sup-dbuser":
      command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE user sup\"",
      environment => ["PGPASSWORD=$psql_password"],
      onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select usename from pg_catalog.pg_user where usename='sup'\" | grep rows",
    } ->

    exec { "create-sup-db":
      command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE DATABASE sup\"",
      environment => ["PGPASSWORD=$psql_password"],
      onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select datname from pg_catalog.pg_database where datname='sup'\" | grep rows",
    } ->

    exec { "grant-sup-db":
      command => "psql -U postgres -h psql.s.tremoureux.fr -c \"GRANT ALL PRIVILEGES ON DATABASE sup TO sup\"",
      environment => ["PGPASSWORD=$psql_password"],
      onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"SELECT datname,datacl FROM pg_database WHERE datname = 'sup' and('sup=CTc/postgres' = ANY(datacl));\" | grep rows",
    }

}