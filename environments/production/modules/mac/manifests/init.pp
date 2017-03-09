class mac {
  if($::operatingsystem == "darwin"){
    
    package { 'Protect_fireampmac_connector' : 
  	  ensure => installed,
  	  provider => pkgdmg,
  	  source => 'http://puppet.vai.org:8000/puppet_repo/apps/Protect_fireampmac_connector/Protect_fireampmac_connector.pkg',
    }

	# New Package Goes Here
  }
}
