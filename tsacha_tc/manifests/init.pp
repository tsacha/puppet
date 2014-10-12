class tsacha_tc {
    class { 'tsacha_tc::install': }

    service { 'httpd':
      ensure => running,
      require => Package['httpd'],
    }
}
