class mac {
  if($::operatingsystem == "darwin"){
	
	package { 'Protect_fireampmac_connector' : 
		ensure => installed,
		provider => pkgdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Protect_fireampmac_connector/Protect_fireampmac_connector.pkg',
	}

	# New Package Goes Here
  }
}
