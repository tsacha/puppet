class tsacha_common::auth {
  $pubkeys = hiera('pubkeys')

  $pubkeys.each |$k,$v| {
    $key = template("/etc/puppet/modules/tsacha_private/files/ssh/$k.pub")
    $authorized_key = $key.split(' ')[1]
    ssh_authorized_key { $k:
      user => $v['user'],
      type => $v['type'],
      key  => $authorized_key
    }
  }
}
