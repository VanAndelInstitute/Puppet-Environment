require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$rosetta = "#{$vari_software}rosetta/default/rosetta_src_2016.02.58402_bundle.tgz"
$installed_dir = "/opt/rosetta_src_2016.02.58402_bundle/main/source"
$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def rosetta_exists
  return (File.exist?($installed_dir))
end

def install_rosetta
  $cores = `nproc`.to_i - 1
  install_cmd = "./scons.py -j#{$cores} mode=release bin"
  puts install_cmd
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_rosetta
  if !rosetta_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($rosetta, $untar_cmd, $untar_flags) }
    install_rosetta and Puppet.notice("rosetta installed.")
  end 
end

add_rosetta
