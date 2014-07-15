class tsacha_glenn {
  class { 'tsacha_glenn::install': } ->
  class { 'tsacha_glenn::drupal': } ->
  service { 'apache2':
    ensure => running
  }

}