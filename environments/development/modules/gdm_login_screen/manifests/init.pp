class gdm_login_screen {
   
    # create the /cm/share/apps location
    file { 'gdm' :
      path    => '/etc/dconf/profile/gdm',
      ensure  => 'present',
      mode    => '0755',
      content => 'user-db:user
      system-db:gdm
      file-db:/usr/share/gdm/greeter-dconf-defaults',
    }

    file { 'banner_message':
      path    => '/etc/dconf/db/gdm.d/01-banner-message',
      ensure  => present,
      mode    => '0755',
      content => "[org/gnome/login-screen]
      banner-message-enable=true
      banner-message-text=\"For use by CryoEM.\nUse your normal VAI login information to log on.\"",
    }

    file { 'display_user_list':
      path    => '/etc/dconf/db/gdm.d/00-login-screen',
      ensure  => present,
      mode    => '0755',
      content => "[org/gnome/login-screen]
      # Do not show the user list
      disable-user-list=true",
    }

}
