require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$frealign = "#{$vari_software}frealign/default/frealign_v9.11_151031.tar.gz"
$installed_dir = "/opt/frealign_v9.11/"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def frealign_exists
  return (File.exist?($installed_dir))
end


def install_frealign
  install_cmd = "./INSTALL"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_frealign
  if !frealign_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($frealign, $untar_cmd, $untar_flags) }
    install_frealign and Puppet.notice("frealign installed.")
  end 
end

add_frealign
