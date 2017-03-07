class krb5 {
  file { 'krb5.conf' :
    path   => '/etc/krb5.conf',
    ensure => present,
    source => 'puppet:///modules/krb5/krb5.conf',
  }
  
  package { 'krb5-workstation' :
    ensure => present,
  }
}
