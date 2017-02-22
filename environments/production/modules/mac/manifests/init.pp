class mac {
  #if($::operatingsystem == "darwin"){
    
    #package { 'googlechrome' : 
    #ensure => installed,
        #provider => appdmg,
        #source => 'https://puppet.vai.org:8000/puppet_repo/apps/googlechrome/googlechrome.dmg',
        #}
    
    #package { 'puppet-agent-1.9.1.1.osx10.10' :
    #  ensure   => installed,
    #  provider => appdmg,
    #  source   => 'https://puppet.vai.org:8000/puppet_repo/apps/puppet-agent-1.9.1.1.osx10.10/puppet-agent-1.9.1.1.osx10.10.dmg',
    #}
	# New Package Goes Here
    #}
}
