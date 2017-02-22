$vari_software = "/primary/vari/software/"
$unblur = "#{$vari_software}unblur/default/unblur_1.0.2.tar.gz"
$installed_dir = "/opt/unblur_1.0.2/"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def unblur_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? "matt" or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_unblur
  install_cmd = "mv bin/* /usr/local/bin"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_unblur
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless unblur_exists
  Dir.chdir("/opt/"){ untar($unblur, $untar_cmd, $untar_flags) }
    install_unblur and Puppet.notice("unblur installed.")
  end 
end

add_unblur
