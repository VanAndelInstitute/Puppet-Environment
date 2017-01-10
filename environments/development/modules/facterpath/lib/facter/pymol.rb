def pymol_exists
  return (File.exist?("/opt/pymol"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end

def add_pymol
  fqdn = Facter.value(:fqdn).downcase
  return unless (valid_fqdn(fqdn))
  unless pymol_exists
    `cd /opt/`
    `tar xvfj /primary/vari/software/pymol/pymol-v1.8.4.0.tar.bz2`
    Dir.chdir("pymol"){`python setup.py install`}
    Puppet.notice("pymol installed")
  end 
end

add_pymol
