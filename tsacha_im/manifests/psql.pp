class tsacha_im::psql {

   $psql_password = hiera('psql::pwd')
   $im_password = hiera('psql::im_pwd')

   Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

   exec { "create-prosody-dbuser":
     command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE user prosody WITH PASSWORD '$im_password'\"",
     environment => ["PGPASSWORD=$psql_password"],
     onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select usename from pg_catalog.pg_user where usename='prosody'\" | grep rows",
   } ->

   exec { "create-prosody-db":
     command => "psql -U postgres -h psql.s.tremoureux.fr -c \"CREATE DATABASE prosody\"",
     environment => ["PGPASSWORD=$psql_password"],
     onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"select datname from pg_catalog.pg_database where datname='prosody'\" | grep rows",
   } ->

   exec { "grant-prosody-db":
     command => "psql -U postgres -h psql.s.tremoureux.fr -c \"GRANT ALL PRIVILEGES ON DATABASE prosody TO prosody\"",
     environment => ["PGPASSWORD=$psql_password"],
     onlyif => "psql -U postgres -h psql.s.tremoureux.fr -c \"SELECT datname,datacl FROM pg_database WHERE datname = 'prosody' and('prosody=CTc/postgres' = ANY(datacl));\" | grep rows",
   }

}