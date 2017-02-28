class std_centos {
  if ($::operatingsystem =~ /[Cc]entos/ or $::operatingsystem =~ /[Rr]edhat/){
    include common
    include sssd
    include graylog
    include privileges
    include dummy_login
  }
}
