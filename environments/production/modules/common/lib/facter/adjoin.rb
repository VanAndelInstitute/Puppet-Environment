#encoding = utf-8
join_info = Dir.chdir(File.dirname(__FILE__)){File.read("ad_join_info.json")}
info_hash = JSON.parse(join_info)
$domain         = info_hash["domain"]
$ad_admin       = info_hash["username"]
$ad_admin_pass  = info_hash["password"]
$host           = info_hash["host"]

##
#   Test for AD Join, OS dependent
#
#   @param os : OS of machine to test
#   @return : true if joined, false otherwise
##
def joined (os)
  case os
  when "darwin" then return ((`dsconfigad -show | awk '/Active Directory Domain/{print $NF}'`).include? $host)
  when "redhat","centos" then return sssd_status
  when "windows" then return true
  else  Puppet.notice("Error in AD join. #{os} not currently supported through Puppet.")
  end
  
  # short circuit the adjoin if the os is not supported
  return true
end

##
#   Join the machine to the AD, OS dependent
#
#   @param os : OS of machine to join
##
def adjoin (os)
  return if joined(os)
  fqdn = Facter.value(:fqdn)
  Puppet.notice("Joining #{fqdn} to the domain.")
  
  case os
  when "darwin" 
    (`dsconfigad -add #{$host} -u #{$ad_admin} -p #{$ad_admin_pass} -domain #{$domain}`)
  when "redhat","centos"
	(`/usr/bin/net ads join -U #{$ad_admin}%#{$ad_admin_pass} createcomputer=LinuxMachines`)
    (`/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --updateall`)
  end
end

def sssd_status
  output = (`systemctl status sssd`).downcase
  if (output =~ /could\snot\sbe\sfound/)
    return true
  end

  !(output =~ /failed|dead/)
end

# Grab the OS from Facter and attempt to join the machine to the AD
adjoin(Facter.value(:operatingsystem).downcase)
