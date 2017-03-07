class mac {
  if($::operatingsystem == "darwin"){
    
    package { 'Protect_fireampmac_connector' : 
  	  ensure => installed,
  	  provider => pkgdmg,
  	  source => 'http://puppet.vai.org:8000/puppet_repo/apps/Protect_fireampmac_connector/Protect_fireampmac_connector.pkg',
    }
  
    package { 'Firefox_51.0' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://puppet.vai.org:8000/puppet_repo/apps/Firefox_51.0/Firefox_51.0.dmg',
	}

	# New Package Goes Here
  }
}
