require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$namd = "#{$vari_software}namd/default/NAMD_CVS-2017-02-16_Linux-x86_64-multicore-CUDA.tar.gz"
$installed_dir = "/opt/NAMD_CVS-2017-02-16_Linux-x86_64-multicore-CUDA/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def namd_exists 
  return (File.exist?($installed_dir))
end


def install_namd
  install_cmd = "cp namd2 /usr/bin/namd2"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_namd
  if !namd_exists and valid_fqdn(Facter.value(:fqdn).downcase)
    Dir.chdir("/opt/"){ untar($namd, $untar_cmd, $untar_flags) }
    install_namd and Puppet.notice("namd installed.")
  end
end 

add_namd
