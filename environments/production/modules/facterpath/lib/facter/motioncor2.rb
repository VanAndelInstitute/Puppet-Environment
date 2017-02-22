$vari_software = "/primary/vari/software/"
$motioncor2 = "#{$vari_software}motioncor2/default/MotionCor2-01-30-2017.tar.gz"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def motioncor2_exists
  return (File.exist?("/usr/local/bin/motioncor2"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_motioncor2
  install_cmd = "mv MotionCor2-01-30-2017 /usr/local/bin/motioncor2"
  Dir.chdir("/opt"){ `#{install_cmd}` }
end

def add_motioncor2
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless motioncor2_exists
  Dir.chdir("/opt/"){ untar($motioncor2, $untar_cmd, $untar_flags) }
    install_motioncor2 and Puppet.notice("motioncor2 installed.")
  end 
end

add_motioncor2
