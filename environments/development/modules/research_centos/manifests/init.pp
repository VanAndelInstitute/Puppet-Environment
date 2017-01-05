class research_centos {
  if ($::operatingsystem == 'centos' or $::operatingsystem == 'redhat'){
    include common
    include sssd
    include mount_drives
    include environment_modules
    include graylog
  }
}
