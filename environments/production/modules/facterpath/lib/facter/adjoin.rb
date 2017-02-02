#encoding = utf-8
Dir.chdir(File.dirname(__FILE__))

info_hash = JSON.parse(File.read("ad_join_info.json"))
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
  when "darwin"
    return ((`dsconfigad -show | awk '/Active Directory Domain/{print $NF}'`).include? $host)
  when "redhat","centos"
    return (!(`systemctl status sssd`).include? "failed")
  when "windows"
    return true
  else
    Puppet.notice("Error in AD join. #{os} not currently supported through Puppet.")
    return true
  end
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
	(`/usr/bin/net ads join -U #{$ad_admin}%#{$ad_admin_pass}`)
    (`/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --updateall`)
  end
end

# Grab the OS from Facter and attempt to join the machine to the AD
adjoin(Facter.value(:operatingsystem).downcase)
