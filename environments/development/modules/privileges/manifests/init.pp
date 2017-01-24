 class privileges {
  
  sudo::conf { 'hpcadmins':
    ensure  => present,
    content => '%hpcadmins ALL=(ALL) ALL',
  }
}
