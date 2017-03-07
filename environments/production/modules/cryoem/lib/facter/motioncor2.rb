require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$motioncor2 = "#{$vari_software}motioncor2/default/MotionCor2-01-30-2017.tar.gz"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def motioncor2_exists
  return (File.exist?("/usr/local/bin/motioncor2"))
end


def install_motioncor2
  install_cmd = "mv MotionCor2-01-30-2017 /usr/local/bin/motioncor2"
  Dir.chdir("/opt"){ `#{install_cmd}` }
end

def add_motioncor2
  if !motioncor2_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($motioncor2, $untar_cmd, $untar_flags) }
    install_motioncor2 and Puppet.notice("motioncor2 installed.")
  end 
end

add_motioncor2
