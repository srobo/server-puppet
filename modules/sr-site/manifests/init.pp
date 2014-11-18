# Root this-is-the-sr-server config file. Fans out to different kinds of service
# we operate.

# git_root: The root URL to access the SR git repositories
class sr-site( $git_root ) {

  # Default PATH
  Exec {
    path => [ '/usr/bin' ],
  }

  # Directory for 'installed flags' for various flavours of data. When some
  # piece of data is loaded from backup/wherever into a database, files here
  # act as a guard against data being reloaded.
  file { '/usr/local/var':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0755',
  }

  file { '/usr/local/var/sr':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0700',
    require => File['/usr/local/var'],
  }

  # Choose speedy yum mirrors
  package { 'yum-plugin-fastestmirror':
    ensure => latest,
  }

  # Anonymous git access
  include gitdaemon

  # The bee
  include bee

  # Monitoring
  class { 'monitoring':
    git_root => $git_root,
  }

  class { 'sr-site::firewall':
    require => File['/usr/local/var/sr'],
  }

  class { 'sr-site::mysql':
    require => File['/usr/local/var/sr'],
  }

  class { 'sr-site::openldap':
    require => File['/usr/local/var/sr'],
  }

  class { 'sr-site::trac':
    git_root => $git_root,
  }

  class { 'sr-site::gerrit':
    require => File['/usr/local/var/sr'],
  }

  include sr-site::subversion
  include sr-site::login
  include sr-site::meta
  include sr-site::ntpd

  class { 'sr-site::git':
    git_root => $git_root,
  }

  # Sends emails to LDAP groups
  class { 'fritter':
    git_root => $git_root,
  }

  # Web stuff
  class { 'www':
    git_root => $git_root,
    require => File['/usr/local/var/sr'],
  }

  class { 'backup':
    git_root => $git_root,
  }

  class { 'pipebot':
    git_root => $git_root,
  }

  class { 'userman':
    git_root => $git_root,
  }

  # Sanity stuff
  package { "rsyslog":
    ensure => latest,
  }

  file {'/etc/systemd/journald.conf':
    ensure => present,
    owner => 'root',
    group => 'root',
    mode => '0755',
    source => 'puppet:///modules/sr-site/journald.conf'
  }
}
