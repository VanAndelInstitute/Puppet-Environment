 class privileges {

  # HPC admins have sudo privileges everywhere
  sudo::conf { 'hpcadmins':
    ensure  => present,
    content => '%hpcadmins ALL=(ALL) ALL',
  }
  
  sudo::conf { 'login':
    ensure  => present,
    content => 'login ALL=(ALL) ALL',
  }

  # give sudo access to specfic teams on their nodes
  # separate machines by their domain name
  case $facts['fqdn'] {
    
    # hli.lab-modify gets sudo access on Lens machines
    /[Ll]ens\d+\.vai\.org/: {
      sudo::conf { 'hli.lab-modify':
        ensure  => present,
        content => '%hli.lab-modify ALL=(ALL) ALL',
      }
    }
    
    # haab.lab-modify gets sudo access on Haab machines
    /[Hh]aab\d+\.vai\.org/: {
      sudo::conf { 'haablabmodify':
        ensure  => present,
        content => '%haab.lab-modify ALL=(ALL) ALL',
      }
    }

    # Anthony Watkins gets sudo access on Biobankdb01
    /[Bb]iobankdb\d+\.vai\.org/: {
      sudo::conf { 'anthonywatkins':
        ensure  => present,
        content => 'anthony.watkins ALL=(ALL) ALL',
      }
    }

    # Gongpu gets sudo access on his machine
    /gongpuvictory\.vai\.org/: {
      sudo::conf { 'gongpuzhao':
        ensure  => present,
        content => 'gongpu.zhao ALL=(ALL) ALL',
      }
    }
  }
}
