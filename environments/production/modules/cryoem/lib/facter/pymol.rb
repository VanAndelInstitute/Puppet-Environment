require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$pymol = "#{$vari_software}pymol/pymol-v1.8.4.0.tar.bz2"
$installed_dir = "/opt/pymol/"

$untar_cmd      = "tar"
$untar_flags    = "xvfj" 

def pymol_exists
  return (File.exist?($installed_dir))
end


def install_pymol
  install_cmd = "python pymol install"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_pymol
  if !pymol_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($pymol, $untar_cmd, $untar_flags) }
    install_pymol and Puppet.notice("pymol installed.")
  end 
end

add_pymol
