$vari_software = "/primary/vari/software/"
$resmap = "#{$vari_software}resmap/default/ResMap-1.1.4-linux64"
$installed_dir = "/usr/local/bin/resmap"

$untar_cmd      = ""
$untar_flags    = "" 

def resmap_exists
  return (File.exist?($installed_dir))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("matt") or fqdn.include? ("gongpu"))
end

def untar(file, cmd, flags)
  `#{cmd} #{flags} #{file}`
end

def add_resmap
  return unless valid_fqdn (Facter.value(:fqdn).downcase)
  unless resmap_exists
  Dir.chdir("/opt/"){ `cp #{$resmap}  #{$installed_dir}` }
  Puppet.notice("resmap installed.")
  end 
end

add_resmap
