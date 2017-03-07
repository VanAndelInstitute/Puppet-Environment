require_relative 'lib/valid_fqdn'

def spider_exists
  return (File.exist?("/usr/bin/spider"))
end

def add_spider
  if !spider_exists and valid_fqdn (Facter.value(:fqdn).downcase)
    Dir.chdir("/opt"){`tar -zxvf /primary/vari/software/spiderweb/spiderweb.21.11.tar.gz`}
    Dir.chdir("spider/bin"){`mv spider_linux_mp_intel64 /usr/bin/spider`}
    Puppet.notice("spider/web installed")
  end 
end

add_spider
