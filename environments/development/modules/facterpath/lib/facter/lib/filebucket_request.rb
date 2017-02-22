##
# Function that runs a filebucket request and returns the result.
##
def filebucket_request (type, file: "", sum: "") 
  return silence_output {(`puppet filebucket get #{sum} --server #{$server}`)}               if type.to_s == "get"
  return silence_output {(`puppet filebucket restore #{file} #{sum} --server #{$server}`)}   if type.to_s == "restore"
  return silence_output {(`puppet filebucket backup #{file} -l`)}                            if type.to_s == "local_backup" 
  return silence_output {(`puppet filebucket backup #{file} --server #{$server}`)}           if type.to_s == "remote_backup"
  return silence_output {(`puppet filebucket -l list`)}                                      if type.to_s == "list"
end
