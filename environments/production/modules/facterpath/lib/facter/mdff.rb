$vari_software = "/primary/vari/software/"
$mdff = "#{$vari_software}mdff/default/mdff.tar.gz"
$installed_dir = "/opt/mdff/"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

def mdff_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def install_mdff
  `echo "set auto_path [linsert $auto_path 0 /opt/mdff]" >> /opt/vmd-1.9.3/data/.vmdrc`
end

def add_mdff
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless mdff_exists
  Dir.chdir("/opt/"){ untar($mdff, $untar_cmd, $untar_flags) }
    install_mdff and Puppet.notice("mdff installed.")
  end 
end

add_mdff
