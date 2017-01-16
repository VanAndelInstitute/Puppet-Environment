def spider_exists
  return (File.exist?("/usr/bin/spider"))
end

def valid_fqdn(fqdn)
  return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end

def add_spider
  fqdn = Facter.value(:fqdn).downcase
  return unless (valid_fqdn(fqdn))
  unless spider_exists
    `cd /opt/`
    `tar -zxvf /primary/vari/software/spiderweb/spiderweb.21.11.tar.gz`
    Dir.chdir("spider/bin"){`mv spider_linux_mp_intel64 /usr/bin/spider`}
    Puppet.notice("spider/web installed")
  end 
end

add_spider
