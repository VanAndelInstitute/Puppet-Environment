require_relative 'lib/valid_fqdn'
require_relative 'lib/untar'

$phenix_version = "phenix-1.11.1-2575"
$phenix_installer = "phenix-installer-1.11.1-2575"
$build = "-intel-linux-2.6-x86_64-centos6"

$untar_cmd      = "tar"
$untar_flags    = "-xvf" 

$installed_dir  = "phenix-installer-1.11.1-2575-intel-linux-2.6-x86_64-centos6"

def phenix_exists
  return (File.exist?("/usr/local/#{$phenix_version}"))
end


def install_pymol
  install_cmd = "./install"
  Dir.chdir($installed_dir){ `#{install_cmd}` }
end

def add_phenix
  if !phenix_exists and valid_fqdn (Facter.value(:fqdn).downcase)
    Dir.chdir("/opt"){ untar("#{$phenix_installer}#{build}", $untar_cmd, $untar_flags) }
    install_phenix and Puppet.notice("Phenix installed.")
  end 
end

add_phenix
