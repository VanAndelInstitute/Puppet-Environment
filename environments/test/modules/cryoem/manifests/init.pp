class cryoem {
  if ($::operatingsystem == 'centos' or $::operatingsystem == 'redhat'){
    include research_centos
    include gdm_login_screen
  }
}
