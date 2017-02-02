$phenix_version = "phenix-1.11.1-2575"
$phenix_installer = "phenix-installer-1.11.1-2575"
$build = "-intel-linux-2.6-x86_64-centos6"
def phenix_exists
  return (File.exist?("/usr/local/#{$phenix_version}"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end

def add_phenix
  fqdn = Facter.value(:fqdn).downcase
  return unless (valid_fqdn(fqdn))
  unless phenix_exists
    `cd /opt/`
    `tar -xvf /primary/vari/software/phenix/#{$phenix_installer}#{$build}.tar.gz`
    Dir.chdir("phenix-installer-1.11.1-2575-intel-linux-2.6-x86_64-centos6"){`./install`}
    Puppet.notice("phenix installed")
  end 
end

add_phenix
