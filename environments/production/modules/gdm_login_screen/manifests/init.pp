class gdm_login_screen {
   
    # create the /cm/share/apps location
    file { 'gdm' :
      path    => '/etc/dconf/profile/gdm',
      ensure  => 'present',
      mode    => '0755',
      source  => 'puppet:///modules/gdm_login_screen/gdm_profile',
    }

    file { 'banner_message':
      path   => '/etc/dconf/db/gdm.d/01-banner-message',
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/gdm_login_screen/banner_msg',
    }

    file { 'display_user_list':
      path   => '/etc/dconf/db/gdm.d/00-login-screen',
      ensure => present,
      mode   => '0755',
      source => 'puppet:///modules/gdm_login_screen/no_users_displayed',
    }

}
