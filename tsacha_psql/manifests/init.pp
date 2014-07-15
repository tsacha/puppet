class tsacha_psql {
    class { 'tsacha_psql::install': } -> 
    class { 'tsacha_psql::sup': }

}