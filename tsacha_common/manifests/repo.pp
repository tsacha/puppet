# repo.pp
#
# Prepare aptitude

class tsacha_common::repo {
  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  
  exec { 'repo_changed_update':
    command => 'yum -y update',
    refreshonly => true
  }

  file { "/etc/yum.repos.d/sensu-unstable.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/sensu.repo.erb'),
    notify => Exec['repo_changed_update']
  }

  file { "/etc/yum.repos.d/epel.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/epel.repo.erb'),
    notify => Exec['repo_changed_update']
  } ->

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_common/epel7-pubkey",
    notify => Exec['repo_changed_update']
  } ->

  package { 'epel-release':
    ensure => installed,
    notify => Exec['repo_changed_update']
  }

  file { "/etc/yum.repos.d/es.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/es.repo.erb'),
    notify => Exec['repo_changed_update']
  } ->

  file { "/etc/yum.repos.d/logstash.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/logstash.repo.erb'),
    notify => Exec['repo_changed_update']
  }

  file { "/etc/yum.repos.d/fedora.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/fedora.repo.erb'),
  }  

  file { "/etc/yum.repos.d/prosody.repo":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    content => template('tsacha_common/prosody.repo.erb'),
    notify => Exec['repo_changed_update']
  }  

  file { "/etc/pki/rpm-gpg/RPM-GPG-KEY-ES-7":
    ensure => present,
    owner => root,
    group => root,
    mode => '0644',
    source => "puppet:///modules/tsacha_common/es-pubkey",
    notify => Exec['repo_changed_update']
  }
}  
