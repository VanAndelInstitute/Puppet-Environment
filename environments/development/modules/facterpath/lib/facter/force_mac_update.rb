def update
  return unless (Facter.value(:operatingsystem) =~ /[Dd]arwin/)
  os_version_hash = (Facter.value(:os))["macosx"]["version"]
  os_version = os_version_hash["major"].to_s + " " + os_version_hash["minor"].to_s

  return ((os_version.include? "10.10") ? "Current version installed." : "Installing latest version.")
end
