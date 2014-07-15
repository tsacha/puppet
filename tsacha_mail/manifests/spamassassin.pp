class tsacha_mail::spamassassin {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  service { 'spamassassin':
    ensure => running
  }

  exec { 'spamassassin-update':
    command => "sa-update",
    refreshonly => true
  }

  exec { 'enable-spamassassin':
    command => "sed -ri 's/(^[^#].+)0/\\11/g' /etc/default/spamassassin",
    onlyif => "grep 'CRON=0' /etc/default/spamassassin",
    notify => Service['spamassassin']
  }

  exec { 'short-circuit':
    command => "sed -i 's/# loadplugin Mail::SpamAssassin::Plugin::Shortcircuit/loadplugin Mail::SpamAssassin::Plugin::Shortcircuit/g' /etc/spamassassin/v320.pre",
    onlyif => "grep '# loadplugin Mail::SpamAssassin::Plugin::Shortcircuit' /etc/spamassassin/v320.pre",
    notify => Service['spamassassin']
  }

  file { '/etc/spamassassin/local.cf':
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    content => template('tsacha_mail/spamassassin/local.cf.erb'),
    notify => Service['spamassassin']
  }

  file { '/etc/cron.daily/spam-imap':
    owner => root,
    group => root,
    mode => 755,
    ensure => present,
    content => template('tsacha_mail/spamassassin/spam-imap.erb')
  }

}