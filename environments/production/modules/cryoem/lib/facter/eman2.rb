require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'
$vari_software = "/primary/vari/software/"
$eman2 = "#{$vari_software}eman2/EMAN2.12/eman2.12.linux64.tar.gz"
$installed_dir = "/opt/EMAN2/"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def eman2_exists
  return (File.exist?($installed_dir))
end


def install_eman2
  install_cmd = "./eman2-installer"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_eman2
  if !eman2_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($eman2, $untar_cmd, $untar_flags) }
    install_eman2 and Puppet.notice("eman2 installed.")
  end 
end

add_eman2
