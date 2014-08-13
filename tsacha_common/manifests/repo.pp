# repo.pp
#
# Prepare aptitude

class tsacha_common::repo {
   Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  class { 'apt':
    purge_sources_list   => true,
    purge_sources_list_d => true,
    purge_preferences_d  => true,
  }

  apt::source { 'testing':
    location          => 'http://ftp.be.debian.org/debian',
    release           => 'testing',
    repos             => 'main contrib non-free',
    include_src       => true,
    notify	      => Exec['repo_changed_update']
  }

  if($lsbdistcodename == "wheezy") {
    apt::source { 'stable':
      location          => 'http://ftp.be.debian.org/debian',
      release           => 'stable',
      repos             => 'main contrib non-free',
      include_src       => true,
      notify            => Exec['repo_changed_update']
    }

    apt::source { 'security':
      location          => 'http://security.debian.org',
      release           => 'wheezy/updates',
      repos             => 'main contrib non-free',
      include_src       => true,
      notify            => Exec['repo_changed_update']
    }

    apt::pin { "stable":
      priority => 700,
      notify   => Exec['repo_changed_update']
    }

    apt::pin { "testing":
      priority => 400,
      notify   => Exec['repo_changed_update']
    }
  }

  if($lsbdistcodename == "jessie") {
    apt::pin { "testing":
      priority => 700,
      notify   => Exec['repo_changed_update']
    }
  }

  exec { 'repo_changed_update':
    command => '/usr/bin/apt-get update',
    refreshonly => true
  }


  apt::source { 'elasticsearch-1.3':
    location          => 'http://packages.elasticsearch.org/elasticsearch/1.3/debian',
    release           => 'stable',
    repos             => 'main',
    include_src       => false,
    notify	      => Exec['repo_changed_update']
  }

  apt::key { 'puppetlabs':
    key        => 'D88E42B4',
    key_source => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    notify     => Exec['repo_changed_update']
  }

  apt::key { 'sensu':
    key => '7580C77F',
    key_source => 'http://repos.sensuapp.org/apt/pubkey.gpg'
  }

  apt::source { 'sensu':
    location => 'http://repos.sensuapp.org/apt',
    release => 'sensu',
    repos => 'main',
    include_src => false,
  }

}  
