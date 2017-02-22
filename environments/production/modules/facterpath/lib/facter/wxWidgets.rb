$vari_software = "/primary/vari/software/"
$wxWidgets = "#{$vari_software}wxWidgets/default/wxWidgets-3.0.2.tar.bz2"
$installed_dir = "/opt/wxWidgets-3.0.2/"

$untar_cmd      = "tar"
$untar_flags    = "xvfj" 

def wxWidgets_exists
  return (File.exist?("/usr/local/bin/wxrc"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_wxWidgets
  install_cmd = "mkdir gtk-build; cd gtk-build; ../configure; make; make install"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_wxWidgets
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless wxWidgets_exists
  Dir.chdir("/opt/"){ untar($wxWidgets, $untar_cmd, $untar_flags) }
    install_wxWidgets and Puppet.notice("wxWidgets installed.")
  end 
end

add_wxWidgets
