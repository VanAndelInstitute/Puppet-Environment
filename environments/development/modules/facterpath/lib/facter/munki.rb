# encoding: utf-8
Dir.chdir(File.dirname(__FILE__))

$host                    = (JSON.parse(File.read("munki_info.json")))["host"]
$repo                    = (JSON.parse(File.read("munki_info.json")))["repo"]
$munki_app               = "/Applications/Managed\ Software\ Center.app"
$munki_tools_version     = "munkitools-2.8.2.2855.pkg"

def munki_installed
  return File.exists? ($munki_app)
end

def install_munki
  Dir.chdir("/var/root/") do
    fqdn = Facter.value(:fqdn).downcase

    # grab and install the munki tools package
    `curl "#{$host}#{$repo}/#{$munki_tools_version}" -o "#{$munki_tools_version}"`
    `installer -pkg #{$munki_tools_version} -target /`
    
    # ensure that munki is configured correctly
    `sudo defaults write /Library/Preferences/ManagedInstalls SoftwareRepoURL "#{$host}#{$repo}"`
    `sudo defaults write /Library/Preferences/ManagedInstalls ClientIdentifier "#{fqdn}"`
    
    # munki tools require a restart (could just print a warning here and not force it)
    Puppet.warning "Munki tools installed. A restart is required for use, please restart at your convenience."
  end
end

def run_munki

  # without the --installonly tag, munki searchs and downloads new software but will not install it
  # thus both calls are needed to both check for and install new software
  Puppet.notice "Checking for new software via Munki."
  `managedsoftwareupdate`
  Puppet.notice "Attempting to install new software via Munki."
  `managedsoftwareupdate --installonly`
end

def main
  return unless (Facter.value(:operatingsystem).downcase =~ /[Dd]arwin/)
  # if munki is installed run it, otherwise install it
  munki_installed ? run_munki : install_munki
end

main
