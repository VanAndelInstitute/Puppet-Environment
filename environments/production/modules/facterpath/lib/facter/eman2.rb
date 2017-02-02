def eman2_exists
  return (File.exist?("/opt/EMAN2"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end

def add_eman2
  fqdn = Facter.value(:fqdn).downcase
  return unless (valid_fqdn(fqdn))
  unless eman2_exists
    `cd /opt`
    `tar zxvf /primary/vari/software/eman2/EMAN2.12/eman2.12.linux64.tar.gz`
    Dir.chdir("EMAN2"){`./eman2-installer`}
    Puppet.notice("EMAN2 installed")
  end 
end

add_eman2
