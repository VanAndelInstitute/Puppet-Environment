class mac {
  if($::operatingsystem == "darwin"){
    file {'com.oracle.java.Java-Updater.plist':
      path => '/Library/Preferences/com.oracle.java.Java-Updater.plist',
      ensure => present,
      mode => 644,
      content => '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>JavaAutoUpdateEnabled</key>
        <false/>
</dict>
</plist>',
        }
    file { 'test.txt':
      path => '/Library/Preferences/test.txt',
      ensure => present,
      content => 'TEST',
    }
    file { 'test.txt':
      path => '/Users/matt/test.txt',
      ensure => present,
      content => 'TEST',
    } 
  }
}
