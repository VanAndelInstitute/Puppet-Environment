class std_mac {
  if ($::operatingsystem == 'darwin'){
    include common
    include mac
    include graylog
  }
}
