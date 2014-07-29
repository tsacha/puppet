class tsacha_common::auth {
  $pubkeys = hiera('pubkeys')

  $pubkeys.each |$k,$v| {

    ssh_authorized_key { $k:
      user => $v['user'],
      type => $v['type'],
      key  => template("/etc/puppet/modules/tsacha_private/files/ssh/$k.pub")
    }
  }
}
