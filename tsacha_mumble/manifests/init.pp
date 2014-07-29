class tsacha_mumble {
  class { 'tsacha_mumble::install': } ->

  service { 'mumble-server':
    ensure => running
  }

}