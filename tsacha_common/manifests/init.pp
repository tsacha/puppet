class tsacha_common {
  class { 'tsacha_common::network': }
  class { 'tsacha_common::repo': } ->
  class { 'tsacha_common::utils': }
  class { 'tsacha_common::puppet': }  
  class { 'tsacha_common::auth': }
}
