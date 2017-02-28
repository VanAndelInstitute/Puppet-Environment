class cryoem {
  if ($::operatingsystem =~ /[Cc]entos/ or $::operatingsystem =~ /[Rr]edhat/){
    include research_centos
    include gdm_login_screen
  }
}
