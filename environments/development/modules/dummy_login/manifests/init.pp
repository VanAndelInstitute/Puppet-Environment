class dummy_login {

  file { '/etc/cron.d/dummy_login' :
    ensure => present,
    mode   => '0700',
    source => 'puppet:///modules/dummy_login/dummy_login',
  } 
  file {'/etc/crontab' :
    ensure => absent,
  }
}
