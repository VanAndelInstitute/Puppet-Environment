require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$Gctf = "#{$vari_software}Gctf/default/Gctf_v1.06_and_examples.tar.gz"
$installed_dir = "/opt/Gctf_v1.06/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def gctf_exists
  return (File.exist?($installed_dir))
end


def install_Gctf
  install_cmd = "mv bin/Gctf-v1.06_sm_30_cu8.0_x86_64 /usr/bin/gctf"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_Gctf
  if !gctf_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($Gctf, $untar_cmd, $untar_flags) }
    install_Gctf and Puppet.notice("Gctf installed.")
  end 
end

add_Gctf
