##
#   Silence the output of input commands
#   to reduce warning and error noise
#   produced by outside tools.
##

def silence_output
  n = (RUBY_PLATFORM =~ /mingw/) ? 'NUL' : '/dev/null'

  begin
    orig_stderr = $stderr.clone
    orig_stdout = $stdout.clone
    $stderr.reopen File.new(n, 'w')
    $stdout.reopen File.new(n, 'w')
    retval = yield
  rescue Exception => e
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
    raise e
  ensure
    $stdout.reopen orig_stdout
    $stderr.reopen orig_stderr
  end 
  retval
end
