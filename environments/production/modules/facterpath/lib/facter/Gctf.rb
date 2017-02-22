$vari_software = "/primary/vari/software/"
$Gctf = "#{$vari_software}Gctf/default/Gctf_v1.06_and_examples.tar.gz"
$installed_dir = "/opt/Gctf_v1.06/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def gctf_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_Gctf
  install_cmd = "mv bin/Gctf-v1.06_sm_30_cu8.0_x86_64 /usr/bin/gctf"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_Gctf
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless gctf_exists
  Dir.chdir("/opt/"){ untar($Gctf, $untar_cmd, $untar_flags) }
    install_Gctf and Puppet.notice("Gctf installed.")
  end 
end

add_Gctf
