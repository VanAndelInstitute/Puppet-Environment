require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$vari_software = "/primary/vari/software/"
$unblur = "#{$vari_software}unblur/default/unblur_1.0.2.tar.gz"
$installed_dir = "/opt/unblur_1.0.2/"

$untar_cmd      = "tar"
$untar_flags    = "zxvf" 

def unblur_exists
  return (File.exist?($installed_dir))
end


def install_unblur
  install_cmd = "mv bin/* /usr/local/bin"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_unblur
  if !unblur_exists and valid_fqdn (Facter.value(:fqdn).downcase)
  Dir.chdir("/opt/"){ untar($unblur, $untar_cmd, $untar_flags) }
    install_unblur and Puppet.notice("unblur installed.")
  end 
end

add_unblur
