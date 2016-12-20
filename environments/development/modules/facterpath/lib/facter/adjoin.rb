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
    # unable to find a command that to accurately determine join status
    # will return to this later, for now repeated joins do not break the system
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
 
  # Join the machine, command depends on OS 
  case os
  when "darwin"
    (`dsconfigad -add #{$host} -u #{$ad_admin} -p #{$ad_admin_pass} -domain #{$domain}`)
  when "redhat","centos"
	(`/usr/bin/net ads join -U #{$ad_admin}%#{$ad_admin_pass}`)
    (`/usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --updateall`)
  when "windows"
    puts "Automatic ADjoin is not currently supported through Puppet on Windows."
  else
    puts "Error in AD join. #{os} not currently supported through Puppet."
  end
end

# Grab the OS from Facter and attempt to join the machine to the AD
adjoin(Facter.value(:operatingsystem).downcase)