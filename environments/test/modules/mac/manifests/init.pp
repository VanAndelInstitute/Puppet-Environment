class mac {
  if($::operatingsystem == "darwin"){
	
	package { 'Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US/Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US.dmg',
	}

	package { 'Firefox_51.0' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Firefox_51.0/Firefox_51.0.dmg',
	}

	# New Package Goes Here
  }
}
