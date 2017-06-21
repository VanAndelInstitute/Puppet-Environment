$os = Facter.value(:operatingsystem)
def get_packages
  $cmd = "/opt/puppetlabs/bin/puppet" if $os =~ /[Cc]entos/
  $cmd ||= "puppet"
  packages = ($os != 'darwin') ? (`#{$cmd} resource package`).split(/\n/).each_slice(3).map { |slice| slice.join("\n") } : []
  (`system_profiler SPApplicationsDataType`).scan(/(.)+:(\s)+Version:(.)+/) { packages << $~ } if ($os == 'darwin')
  packages 
end
