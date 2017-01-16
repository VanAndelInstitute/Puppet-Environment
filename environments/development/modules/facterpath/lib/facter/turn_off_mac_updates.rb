$disable_count = 3

def currently_disabled
  all_disabled = `plutil -convert xml1 -o - /Library/Preferences/com.apple.commerce.plist|grep -c false`
  return (all_disabled.to_i >= $disable_count)
end

def disable_updates(os)
  return unless (os =~ /[Dd]arwin/)
  unless currently_disabled
    Puppet.warning "Automatic Updates enabled. Disabling automatic updates now."
    `defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool FALSE`
    `defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool FALSE`
    `defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool FALSE`
  end
end
disable_updates(Facter.value(:operatingsystem).downcase)
