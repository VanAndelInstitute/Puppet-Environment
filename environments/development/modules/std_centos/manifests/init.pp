class std_centos {
  if ($::operatingsystem == 'centos' or $::operatingsystem == 'redhat'){
    include common
    include sssd
    include graylog
  }
}
