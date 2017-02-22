def coot_exists
  return (File.exist?("/opt/coot-Linux-x86_64-rhel-6-gtk2-python"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end

def add_coot
  return unless valid_fqdn Facter.value(:fqdn).downcase
  unless coot_exists
    Dir.chdir("/opt/"){`tar -zxvf /primary/vari/software/coot/coot-0.8.7-binary-Linux-x86_64-rhel-6-python-gtk2.tar.gz`}
    Puppet.notice("Coot installed.")
  end 
end

add_coot
