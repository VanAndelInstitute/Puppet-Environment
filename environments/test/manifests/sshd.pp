class sshd {

  service { 'sshd':
    enable => true,
    ensure => running,
  }

}

