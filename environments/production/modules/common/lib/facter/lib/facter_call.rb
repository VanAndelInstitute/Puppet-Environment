require_relative 'silence_output'

##
#   Sanitize the Facter.value call
##

def facter_call(val)
  return silence_output{Facter.value(val.to_sym)}
end
