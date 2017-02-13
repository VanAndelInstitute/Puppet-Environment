class windows_server {
  if ($::operatingsystem == 'windows'){
    include std_windows
  }
}
