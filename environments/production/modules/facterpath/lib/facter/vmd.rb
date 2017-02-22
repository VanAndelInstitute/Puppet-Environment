$vari_software = "/primary/vari/software/"
$vmd = "#{$vari_software}vmd/default/vmd-1.9.3.bin.LINUXAMD64-CUDA8-OptiX4-OSPRay111p1.opengl.tar.gz"
$installed_dir = "/opt/vmd-1.9.3/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def vmd_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_vmd
  install_cmd = "./configure; cd src; make install"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_vmd
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless vmd_exists
  Dir.chdir("/opt/"){ untar($vmd, $untar_cmd, $untar_flags) }
    install_vmd and Puppet.notice("vmd installed.")
  end 
end

add_vmd
