class graylog {
  if($::operatingsystem == 'darwin'){
	file_line { 'graylog' :
		path => '/etc/syslog.conf',
        
        # UDP required for MacOS systems
		line => '*.* @graylog.vai.org:514',
	}
  }
  elsif ($::operatingsystem == 'redhat' or $::operatingsystem == 'centos'){
    file_line { 'graylog' :
      path => '/etc/rsyslog.conf',

      # Prefer TCP for Linux machines
      line => '*.* @@graylog.vai.org:514',
    }
  }
}
