class mac {
  if($::operatingsystem == "darwin"){
	
	package { 'Protect_fireampmac_connector' : 
		ensure => installed,
		provider => pkgdmg,
		source => 'http://munki.vai.org/puppet_repo/apps/Protect_fireampmac_connector/Protect_fireampmac_connector.pkg',
	}

	package { 'googlechrome' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/puppet_repo/apps/googlechrome/googlechrome.dmg',
	}

	package { 'Firefox_51.0' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/puppet_repo/apps/Firefox_51.0/Firefox_51.0.dmg',
	}

	# New Package Goes Here
  }
}
