class research_centos {
  if ($::operatingsystem == 'centos' or $::operatingsystem == 'redhat'){
    include std_centos
    include mount_drives
    include environment_modules
  }
}
