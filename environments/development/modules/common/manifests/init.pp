class common {
  if ($::operatingsystem != 'windows'){
    $doc_root = '/root/'
    file { '/bin/puppet' :
      ensure             => present,
      source             => '/opt/puppetlabs/puppet/bin/puppet',
      source_permissions => use,
    }   
    file { '/bin/facter' :
      ensure => present,
      source => '/opt/puppetlabs/puppet/bin/facter',
    }
	service { 'puppet':
		ensure	=> 'running',
		enable	=> true,
	}
  }	
}
