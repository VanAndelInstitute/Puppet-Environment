$vari_software = "/primary/vari/software/"
$gautomatch = "#{$vari_software}gautomatch/default/Gautomatch_v0.53_and_examples.tar.gz"
$installed_dir = "/opt/Gautomatch_v0.53"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def gautomatch_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_gautomatch
  install_cmd = "mv bin/Gautomatch-v0.53_sm_20_cu8.0_x86_64 /usr/bin/gautomatch"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_gautomatch
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless gautomatch_exists
  Dir.chdir("/opt/"){ untar($gautomatch, $untar_cmd, $untar_flags) }
    install_gautomatch and Puppet.notice("gautomatch installed.")
  end 
end

add_gautomatch
