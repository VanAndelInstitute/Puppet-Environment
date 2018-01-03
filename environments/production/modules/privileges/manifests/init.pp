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

  # separate machines by their domain name, sudo access files are
  # retrieved from /etc/puppetlabs/code/environments/productions/modules/privileges/files
  case $facts['fqdn'] {
   
    /[Ll]ens\d+\.vai\.org/: {
      sudo::conf { 'lens':
        ensure => present,
        source => 'puppet:///modules/privileges/lens',
      }
    }
    
    /[Hh]aab\d+\.vai\.org/: {
      sudo::conf { 'haab':
        ensure => present,
        source => 'puppet:///modules/privileges/haab',
      }
    }
    
    /[Bb]iobankdb\d+\.vai\.org/: {
      sudo::conf { 'biobankdb':
        ensure => present,
        source => 'puppet:///modules/privileges/biobankdb',
      }
    }
    
    /[Oo]ne\.vai\.org/: {
      sudo::conf { 'one':
        ensure => present,
        source => 'puppet:///modules/privileges/one',
      }
    }

    /[Gg]ongpuvictory\.vai\.org/: {
      sudo::conf { 'gongpu':
        ensure => present,
        source => 'puppet:///modules/privileges/gongpu',
      }
    }
    
    /[Ll]nxweb\d+\.vai\.org/: {
      sudo::conf { 'lnxweb':
        ensure => present,
        source => 'puppet:///modules/privileges/lnxweb',
      }
    }
    /[Ll]imsdev\d+\.vai\.org/: {
      sudo::conf { 'limsdev':
        ensure => present,
        source => 'puppet:///modules/privileges/limsdev',
      }
    }
 } 
}
