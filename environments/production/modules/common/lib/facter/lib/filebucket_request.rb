##
# Function that runs a filebucket request and returns the result.
##
def filebucket_request (type, file: "", sum: "")
  $cmd = "/opt/puppetlabs/bin/puppet" if (Facter.value(:operatingsystem) =~ /[Dd]arwin/); $cmd = "puppet" if (Facter.value(:operatingsystem) =~ /[Ww]indows/); $cmd ||= "/opt/puppetlabs/bin/puppet" # full path required for mac
  return silence_output {(`#$cmd filebucket get #{sum} --server #{$server}`)}               if type.to_s == "get"
  return silence_output {(`#$cmd filebucket restore #{file} #{sum} --server #{$server}`)}   if type.to_s == "restore"
  return silence_output {(`#$cmd filebucket backup #{file} -l`)}                            if type.to_s == "local_backup" 
  return silence_output {(`#$cmd filebucket backup #{file} --server #{$server}`)}           if type.to_s == "remote_backup"
  return silence_output {(`#$cmd filebucket -l list`)}                                      if type.to_s == "list"
end
