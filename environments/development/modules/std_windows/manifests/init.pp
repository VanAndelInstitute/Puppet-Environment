class std_windows {
  if ($::operatingsystem == 'windows'){
    include common
    include windows
  }
}
