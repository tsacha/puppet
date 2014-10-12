# containers.pp
#
# Containers generation

class tsacha_hypervisor::containers {

  $hosts = hiera('hosts')
  $hosts[$hostname].each |$k,$v| {
    $cont = $k
    if($k != "physical") {
      tsacha_hypervisor::generic { $cont: }
    }
  }

}