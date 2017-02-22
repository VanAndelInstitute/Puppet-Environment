class dummy_login {

  file { '/etc/cron.d/dummy_login' :
  ensure => present,
  mode  => '0700',
  content   =>
      '## This file is managed by Puppet.
# Ensure /etc/krb5.keytab doesnt expire
30 2 * * * root /usr/bin/id matthew.hoffman'
  }
  file {'/etc/crontab' :
    ensure => absent,
  }
}
