class cryoem {
  if ($::operatingsystem =~ /[Cc]entos/ or $::operatingsystem =~ /[Rr]edhat/){
    include research_centos
    include gdm_login_screen

    exec { '/opt/cryosparc/bin/cryosparc start':
      #path   => '/usr/bin:/usr/sbin:/bin:/opt/cryosparc/bin',
      onlyif => '/opt/cryosparc/bin/cryosparc start |grep Error:',
    }

  }
}
