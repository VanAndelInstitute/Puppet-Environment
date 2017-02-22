$vari_software = "/primary/vari/software/"
$namd = "#{$vari_software}namd/default/NAMD_CVS-2017-02-16_Linux-x86_64-multicore-CUDA.tar.gz"
$installed_dir = "/opt/NAMD_CVS-2017-02-16_Linux-x86_64-multicore-CUDA/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def namd_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  puts"#{cmd} #{flags} #{file}"
  `#{cmd} #{flags} #{file}`
end

def install_namd
  install_cmd = "cp namd2 /usr/bin/namd2"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_namd
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless namd_exists
  Dir.chdir("/opt/"){ untar($namd, $untar_cmd, $untar_flags) }
    install_namd and Puppet.notice("namd installed.")
  end 
end

add_namd
