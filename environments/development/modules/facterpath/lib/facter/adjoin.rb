$domain         = "vaidc02.vai.org"
$ad_admin       = "admMattH"
$ad_admin_pass  = "Puppetisc00l"
$host           = "vai.org"
$test_user      = "matthew.hoffman"

##
#   Test for AD Join, OS dependent
#
#   @param os : OS of machine to test
#   @return : true if joined, false otherwise
##
def joined (os)
  case os
  when "darwin"
    return ((`dsconfigad -show | awk '/Active Directory Domain/{print $NF}'`).include? "vai")
  when "redhat","centos"
    return ((`net ads info`).include? "vai")
  else
    puts "Error in AD join. #{os} not currently supported through Puppet."
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

  # Join the machine, command depends on OS 
  case os
  when "darwin"
    #Puppet.err("#{fqdn} was not joined to the AD. Joining now.")
    (`dsconfigad -add #{$host} -u #{$ad_admin} -p #{$ad_admin_pass} -domain #{$domain}`)
  when "redhat","centos"
    #Puppet.err("#{fqdn} was not joined to the AD. Joining now.")
	(`/usr/bin/net ads join -U #{$ad_admin}%#{$ad_admin_pass}`)
    (`/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --updateall`)
  end
end

# Grab the OS from Facter and attempt to join the machine to the AD
adjoin(Facter.value(:operatingsystem).downcase)
