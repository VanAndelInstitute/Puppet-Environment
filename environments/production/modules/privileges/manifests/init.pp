 class privileges {
  
  sudo::conf { 'hpcadmins':
    ensure  => present,
    content => '%hpcadmins ALL=(ALL) ALL',
  }

  #if ($::fqdn =~ /^lens\d+$/){
    sudo::conf { 'hli.lab-modify':
      ensure  => present,
      content => '%hli.lab-modify ALL=(ALL) ALL',
    }
    #}
  #if ($::fqdn =~ /^lens\d+$/){
    sudo::conf { 'haab.lab-modify':
      ensure  => present,
      content => '%haab.lab-modify ALL=(ALL) ALL',
    }
    #}
}
