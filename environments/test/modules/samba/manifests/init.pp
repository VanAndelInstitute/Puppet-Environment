class samba {
  package { 'samba' :
    ensure => present,
  }

  file { '/etc/samba/smb.conf' :
    ensure => present,
    source => 'puppet:///modules/samba/smb.conf',
  }
}
