class mac {
  if($::operatingsystem == "darwin"){
	
	package { 'Firefox_51.0' : 
		ensure => installed,
		provider => appdmg,
		source => 'http://munki.vai.org/munki_repo/pkgs/apps/Firefox_51.0/Firefox_51.0.dmg',
	}

	# New Package Goes Here
  }
}
