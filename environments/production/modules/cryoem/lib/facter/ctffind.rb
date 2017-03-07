require_relative 'lib/valid_fqdn'

$vari_software = "/primary/vari/software/"
$ctffind = "#{$vari_software}ctffind/default/bin/*"

def ctffind_installed
  return (File.exist? ("/usr/bin/ctffind"))
end

def install_ctffind
  `cp #{$ctffind} /usr/bin`
end

def add_ctffind
  if !ctffind_installed and valid_fqdn Facter.value(:fqdn).downcase
    install_ctffind and Puppet.notice("ctffind installed.")
  end
end

add_ctffind
