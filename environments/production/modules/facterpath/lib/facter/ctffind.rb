$vari_software = "/primary/vari/software/"
$ctffind = "#{$vari_software}ctffind/default/bin/*"

def ctffind_installed
  return (File.exist? ("/usr/bin/ctffind"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def install_ctffind
  `cp #{$ctffind} /usr/bin`
end

def add_ctffind
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  return if ctffind_installed
    install_ctffind and Puppet.notice("ctffind installed.")
end

add_ctffind
