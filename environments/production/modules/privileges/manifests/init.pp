 class privileges {

  # HPC admins have sudo privileges everywhere
  sudo::conf { 'hpcadmins':
    ensure  => present,
    content => '%hpcadmins ALL=(ALL) ALL',
  }
  
  sudo::conf { 'user':
    ensure  => present,
    content => 'user ALL=(ALL) ALL',
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
    /[Tt]riche\.vai\.org/: {
      sudo::conf { 'triche':
        ensure => present,
        source => 'puppet:///modules/privileges/triche',
      }
    }
    /[Ll]shibtest01\d+\.vai\.org/: {
      sudo::conf { 'shibtest01':
        ensure => present,
        source=> 'puppet:///modules/privileges/shib',
      }
    }
    /[Aa]spen\.vai\.org/: {
      sudo::conf { 'xu':
        ensure => present,
        source => 'puppet:///modules/privileges/xu',
      }
    }
    'szabo1.vai.org': {
      sudo::conf { 'szabo':
        ensure => present,
        source => 'puppet:///modules/privileges/szabo',
      }
    }
    'triche-laptop.vai.org': {
      sudo::conf { 'triche':
        ensure => present,
        source => 'puppet:///modules/privileges/triche',
      }
    }
    /[Bb]ras\d+\.vai\.org/: {
      sudo::conf { 'bras':
        ensure => present,
        source => 'puppet:///modules/privileges/bras',
      }
    }
    
    /[Tt]iedemann\d+\.vai\.org/: {
      sudo::conf { 'rochelle':
        ensure => present,
        source => 'puppet:///modules/privileges/rochelle',
      }
    }
    
    /[Jj]ones\d+\.vai\.org/: {
      sudo::conf { 'jones':
        ensure => present,
        source => 'puppet:///modules/privileges/jones',
      }
    }

 } 
}
