class tsacha_mail {
  class { 'tsacha_mail::packages': } ->
  class { 'tsacha_mail::dovecot': } ->
  class { 'tsacha_mail::ldap': } ->
  class { 'tsacha_mail::dkim': } ->
  class { 'tsacha_mail::postfix': } ->
  class { 'tsacha_mail::spamassassin': }
}
