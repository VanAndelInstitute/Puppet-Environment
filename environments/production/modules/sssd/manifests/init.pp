class sssd {
  include krb5
  include samba

  file { '/etc/sssd/sssd.conf' :
    ensure => present,
    mode   => '0600',
    source => 'puppet:///modules/sssd/sssd.conf'
  }

  package { 'sssd' :
    ensure => present,
  }
    
  exec { 'authconfig-sssd' :
    command     => '/usr/sbin/authconfig --enablesssd --enablesssdauth --disableldap --disableldapauth --enablemkhomedir --updateall', 
    refreshonly => true,
  }
    
  service { 'sssd' :
    ensure    => running,
    enable    => true,
    subscribe => Exec['authconfig-sssd'],
  }

  service { 'crond' :
    subscribe =>  Service['sssd'],
  }
}
