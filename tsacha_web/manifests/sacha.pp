class tsacha_web::sacha {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/", "/usr/local/bin" ] }

  file { "/etc/apache2/sites-available/sacha.conf":
    ensure => present,
    owner => root,
    group => root,
    mode => 640,
    notify => File['/etc/apache2/sites-enabled/sacha.conf'],
    content => template('tsacha_web/sacha.erb'),
  }

  file { '/root/.ssh/deploy-blog.pub':
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    source => "puppet:///modules/tsacha_private/web/deploy-blog.pub",
  }

  file { '/root/.ssh/deploy-blog':
    owner => root,
    group => root,
    mode => 400,
    ensure => present,
    source => "puppet:///modules/tsacha_private/web/deploy-blog",
  } ->

  file { '/root/.ssh/config':
    owner => root,
    group => root,
    mode => 644,
    ensure => present,
    source => "puppet:///modules/tsacha_private/web/ssh-config-blog",
  } ->
  
  exec { 'deploy-blog':
    command => 'git clone git@blog:tsacha/s.tremoureux.fr.git sacha',
    cwd => '/srv/web',
    unless => 'stat /srv/web/sacha'
  }

  package { ['ruby-dev','build-essential','less']:
    ensure => installed,
  } ->

  exec { 'jekyll':
    command => "gem install jekyll",
    unless => 'gem list --local jekyll | grep jekyll'
  } ->

  exec { 'i18n':
    command => "gem install i18n",
    unless => 'gem list --local i18n | grep i18n'
  } ->

  exec { 'kramdown':
    command => "gem install kramdown",
    unless => 'gem list --local kramdown | grep kramdown'
  } ->

  package { 'nodejs':
    ensure => installed
  } ->

  exec { 'build-site':
    command => "jekyll build",
    unless => "stat _site/",
    cwd => "/srv/web/sacha"
  } ~>

  file { "/etc/apache2/sites-enabled/sacha.conf":
    ensure => link,
    target => "/etc/apache2/sites-available/sacha.conf",
    require => Exec['deploy-blog'],
    notify => Service['apache2']
  }

  exec { 'deploy-blog-drafts':
    command => 'git clone git@blog:tsacha/s.tremoureux.fr.git sacha-drafts',
    cwd => '/srv/web',
    unless => 'stat /srv/web/sacha-drafts',
    require => Exec['build-site']
  } ->

  exec { 'build-site-drafts':
    command => "jekyll build",
    unless => "stat _site/",
    cwd => "/srv/web/sacha-drafts",
    notify => File["/etc/apache2/sites-enabled/sacha.conf"]
  }


}