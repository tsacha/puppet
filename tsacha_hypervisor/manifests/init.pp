class tsacha_hypervisor {
  class { 'tsacha_hypervisor::lxc': }
  class { 'tsacha_hypervisor::network': }
  class { 'tsacha_hypervisor::auth': }
  class { 'tsacha_hypervisor::sup': }
}
