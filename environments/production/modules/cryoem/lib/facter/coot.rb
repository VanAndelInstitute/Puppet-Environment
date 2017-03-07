require_relative 'lib/valid_fqdn'

def coot_exists
  return (File.exist?("/opt/coot-Linux-x86_64-rhel-6-gtk2-python"))
end

def add_coot
  if !coot_exists and valid_fqdn Facter.value(:fqdn).downcase
    Dir.chdir("/opt/"){`tar -zxvf /primary/vari/software/coot/coot-0.8.7-binary-Linux-x86_64-rhel-6-python-gtk2.tar.gz`}
    Puppet.notice("Coot installed.")
  end 
end

add_coot
