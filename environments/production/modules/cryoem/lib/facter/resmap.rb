require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$resmap = "#{$vari_software}resmap/default/ResMap-1.1.4-linux64"
$installed_dir = "/usr/local/bin/resmap"

$untar_cmd      = ""
$untar_flags    = "" 

def resmap_exists
  return (File.exist?($installed_dir))
end


def add_resmap
  if !resmap_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ `cp #{$resmap}  #{$installed_dir}` }
  Puppet.notice("resmap installed.")
  end 
end

add_resmap
