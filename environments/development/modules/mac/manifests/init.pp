class mac {
  if($::operatingsystem == "darwin"){
    file {'com.oracle.java.Java-Updater.plist':
      path => '/Library/Preferences/com.oracle.java.Java-Updater.plist',
      ensure => present,
      mode => '644',
      content => '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>JavaAutoUpdateEnabled</key>
        <false/>
</dict>
</plist>',
        }
  }

    file {'com.apple.loginwindow.plist':
      path => '/Library/Preferences/com.apple.loginwindow.plist',
      ensure => present,
      mode => '644',
      content => '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>MCXLaunchAfterUserLogin</key>
        <true/>
        <key>MCXLaunchOnUserLogout</key>
        <dict>
                <key>gangning.liang</key>
                <true/>
        </dict>
        <key>MasterPasswordHint</key>
        <string>this is a test of Puppet writing to plist files</string>
        <key>OptimizerLastRunForBuild</key>
        <integer>29748896</integer>
        <key>OptimizerLastRunForSystem</key>
        <integer>168428800</integer>
        <key>lastUser</key>
        <string>loggedIn</string>
        <key>lastUserName</key>
        <string>matt</string>
</dict>
</plist>',
    }

    package { 'firefox':
      ensure   => present,
      provider => 'homebrew',
    }
}
