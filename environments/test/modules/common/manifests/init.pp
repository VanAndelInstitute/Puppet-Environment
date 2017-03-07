class common {
  if ($::operatingsystem != 'windows'){
	service { 'puppet':
		ensure	=> 'running',
		enable	=> true,
	}
  }	
}
