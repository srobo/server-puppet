class www::phpbb ( $git_root, $root_dir ) {
  $forum_db_name = 'phpbb_sr2013'
  $forum_user = extlookup("phpbb_sql_user")
  $forum_pw = extlookup("phpbb_sql_pw")

  vcsrepo { "${root_dir}":
    ensure => present,
    owner => 'wwwcontent',
    group => 'www',
    provider => git,
    source => "${git_root}/sr-phpbb3.git",
    revision => "master",
    force => true,
    require => Package[ "php" ],
  }

  mysql::db { "$forum_db_name":
    user => $forum_user,
    password => $forum_pw,
    host => 'localhost',
    grant => ['all'],
  }

  file { "${root_dir}/phpBB/config.php":
    ensure => present,
    owner => 'wwwcontent',
    group => 'www',
    mode => '640',
    content => template('www/forum_config.php.erb'),
  }
}
