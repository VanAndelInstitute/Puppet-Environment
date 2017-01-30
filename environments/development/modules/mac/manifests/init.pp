class mac {
  if($::operatingsystem == "darwin"){
  	package { 'googlechrome.dmg' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/googlechrome/googlechrome.dmg',
	}

	package { 'Firefox_51.0' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Firefox_51.0/Firefox_51.0.dmg',
	}

	package { 'munkitools-2.8.2.2855' : 
		ensure => installed,
		provider => pkgdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/munkitools/munkitools.pkg',
	}

	package { 'Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US/Apache_OpenOffice_4.1.3_MacOS_x86-64_install_en-US.dmg',
	}

	package { 'Protect_fireampmac_connector' : 
		ensure => installed,
		provider => pkgdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Protect_fireampmac_connector/Protect_fireampmac_connector.pkg',
	}

	package { 'CiscoJabberMac-11.7.0.241535' : 
		ensure => installed,
		provider => pkgdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/CiscoJabberMac-11.7.0.241535/CiscoJabberMac-11.7.0.241535.pkg',
	}

	# New Package Goes Here
  }
}
