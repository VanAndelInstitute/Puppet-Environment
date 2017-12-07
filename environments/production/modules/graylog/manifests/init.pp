class graylog {
  case $facts['os']['name'] {
    /[Rr]ed[Hh]at|[Cc]ent[OS|os]/:  {$line = '*.* @@graylog.vai.org:514'} # Use TCP for Linux
    #/[Dd]arwin/:                    {$line = '*.* @graylog.vai.org:514'}  # And UDP for Mac
    default:                        {$line = ""}                          # Don't try and configure for Windows
  }

  if(!$line == ""){
    file_line { 'graylog' :
      path => '/etc/syslog.conf',
      line => $line,
    }
  }
  
  if($facts['os']['name'] =~ /[Rr]ed[Hh]at|[Cc]ent[OS|os]/){

    cron { 'uptime check':
      command => '. /usr/bin/uptime_check',
      user    => 'root',
      hour    => '*',
    }

    file { '/usr/bin/uptime_check' :                                                
        ensure => present,                                                          
        mode   => '0777',                                                           
        source => 'puppet:///modules/graylog/uptime_check'                                
    }
  }
}
