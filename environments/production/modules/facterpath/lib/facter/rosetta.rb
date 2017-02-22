$vari_software = "/primary/vari/software/"
$rosetta = "#{$vari_software}rosetta/default/rosetta_src_2016.02.58402_bundle.tgz"
$installed_dir = "/opt/rosetta_src_2016.02.58402_bundle/main/source"
$cores = `nproc`.to_i - 1
$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def rosetta_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_rosetta
  install_cmd = "./scons.py -j#{$cores} mode=release bin"
  puts install_cmd
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_rosetta
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless rosetta_exists
  Dir.chdir("/opt/"){ untar($rosetta, $untar_cmd, $untar_flags) }
    install_rosetta and Puppet.notice("rosetta installed.")
  end 
end

add_rosetta
