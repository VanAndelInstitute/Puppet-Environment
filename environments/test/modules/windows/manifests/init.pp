class windows {
  if($::operatingsystem == "windows"){
	
	package { 'npp.7.3.1.Installer.x64' : 
		ensure => installed,
		provider => windows,
		source => 'http://munki.vai.org/puppet_repo/apps/npp.7.3.1.Installer.x64/npp.7.3.1.Installer.x64.exe',
	}

	package { 'test' : 
		ensure => installed,
		provider => windows,
		source => 'http://puppet.vai.org:8000/puppet_repo/apps/test/test.exe',
	}

	# New Package Goes Here
  }
}
