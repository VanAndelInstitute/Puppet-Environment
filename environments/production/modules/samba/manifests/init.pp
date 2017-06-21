class samba {
  package { 'samba' :
    ensure => present,
  }

  if ($facts['hostname'] != 'one'){
    file { '/etc/samba/smb.conf' :
      ensure => present,
      source => 'puppet:///modules/samba/smb.conf',
    }
  }
}
