class tsacha_hypervisor {
  class { 'tsacha_hypervisor::lxc': }
  class { 'tsacha_hypervisor::network': }
}
