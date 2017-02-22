class windows {
  if($::operatingsystem == "windows"){
	
	package { 'npp.7.3.2.Installer.x64' : 
		ensure => installed,
		provider => windows,
		source => 'https://puppet.vai.org:8000/puppet_repo/apps/npp.7.3.2.Installer.x64/npp.7.3.2.Installer.x64.exe',
	}

	# New Package Goes Here
  }
}
