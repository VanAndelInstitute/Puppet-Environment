# encoding: utf-8
require_relative 'lib/filebucket_request'
require_relative 'lib/silence_output'
require_relative 'lib/facter_call'

##
#   Ruby script used alongside Puppet to retrieve
#   the initial configuration of a machine, store it
#   and use it as a baseline for configuration drift.
##

join_info = Dir.chdir(File.dirname(__FILE__)){File.read("ad_join_info.json")}
$server = (JSON.parse(join_info))["server"]
$os = facter_call(:operatingsystem).downcase
$fqdn = facter_call(:fqdn).downcase
$backup_occured = false
$time = Time.now.utc

##
#   Function that searchs for, and alerts of,
#   any detected drift on the machine.
#
#   @return: yes if drift is found, no otherwise
##
def setup()

  windows_filepath = "C:/ProgramData/PuppetLabs/facter/facts.d/"
  linux_filepath = "/opt/puppetlabs/facter/facts.d/"

  # determine where to store facts based on the OS
  filepath = ($os.include? "windows") ? windows_filepath : linux_filepath
  
  config_file = "#{filepath}#{$fqdn}_configuration.json"
  $drift = "#{filepath}#{$fqdn}_drift.yaml"
  $back = "#{filepath}#{$fqdn}_back.yaml"

  # if the config file does not exist
  unless File.exist? config_file
    # backup the current config as the new standard if a cached sum does not exist
    backup config_file unless restore config_file	
	
  # a configuration file exists, check for inconsistency
  else

    # retrieve the local sum of the file
    sum = Digest::MD5.file config_file

    # attempt to retrieve that sum from the server
    response = filebucket_request(:get, sum: sum)
		
    # if the sum is not returned, it did not exist
    if(response.nil? || response.empty?)
	  # delete the local file and attempt to restore another sum
	  File.delete config_file, $drift
	  (restore config_file) ? Puppet.notice("File found locally but not remotely. Restoring from cached copy.") : (backup config_file)
    end

    # retrieve the current config
    current =  JSON.parse(currentConfig().gsub(/\t|\n/, ""))["packages"]
    
    # retrieve the saved config
    saved = facter_call(:packages) 
    prev_drift = facter_call(:drift) 
   	
    # used to capture the current drift of the system
    $curr_drift = ""
    
    # if the saved config and current config match exactly
    if current == saved
      # send a notice and return
      Puppet.notice ("No drift detected on #{$fqdn}. (#{$time})")
    
    # otherwise drift may exist
    else
      if drift_found(current, saved)
        # capture the previous drift and if it differs from the current drift
        # send an error alert (goes to email)
        prev_drift = facter_call(:drift)
        msg = "Drift detected on #{$fqdn}. (#{$time})"
        (prev_drift == $curr_drift) ? Puppet.error(msg) : Puppet.info(msg)
      else
        Puppet.notice ("No drift detected on #{$fqdn}. (#{$time})")
      end
    end
  end

  File.open($drift, 'w') { |f| f.write("drift: \"#{$curr_drift}\"") }
  File.open($back, 'w') { |f| f.write("backup_occured: \"#{$backup_occured}\"") }
end

##
#   If drift is found this function
#   logs it to Puppet and returns if drift was found.
#
#   @param current: the current packages installed
#   @param saved:   previously found packages 
#
#   @return drift:  was drift found?
##
def drift_found(current, saved)

  drift = false

  # convert the current and saved packages to arrays
  # remove packages found in both to find drift
  c, s = current.to_a, saved.to_a
  difference = (c.size > s.size) ? c - s : s - c
  
  # determine the type of drift for each difference
  difference.each do |d|
    drift = true
    
    # A previously installed package was not found in the current configuration
    if not c.to_s.include? (d["name"])
      msg = d["name"] + " not found on #{$fqdn}. (#{$time})"
    
    # A package was installed after the configuration was retrieved initially.
    elsif not s.to_s.include? (d["name"])
      msg = d["name"] + " " + d["version"] + " installed on #{$fqdn} after configuration. (#{$time})"

    # The found package version differs from the saved package version.
    else 
      c.each do |x|
        msg = x["name"] + " " + x["version"] + " should be " + d["name"] + " " + d["version"] if x["name"] == d["name"] and x["version"] != d["version"]
      end
    end
    Puppet.notice("#{msg}") unless msg.to_s.empty?
    ($curr_drift += msg.to_s) unless($curr_drift.include? msg.to_s)
  end

  return drift
end

##
#	Function that retrieves the current state of the
#	the system and returns it as a string.
#
#	@return str: the current configuration of the machine as a JSON object
##
def currentConfig()

  # retrieve the current configuration
  packages = ($os != 'darwin') ? (`puppet resource package`).split(/\n/).each_slice(3).map { |slice| slice.join("\n") } : []
  (`system_profiler SPApplicationsDataType`).scan(/(.)+:(\s)+Version:(.)+/) { packages << $~ } if ($os == 'darwin')

  ip = facter_call(:ipaddress)      || "NO IP FOUND"
  mac = facter_call(:macaddress)    || "NO MAC FOUND"

  json_array = [] # store packages as hashes for conversion to JSON

  # cycle through the found packages
  packages.each do |pack|
    next if pack.nil? || pack.empty?
	name = ($os == 'darwin') ? (pack.to_s.match(/.*:/).to_s).gsub(/:/, "").strip : ((pack.match(/\'.*\':/)).to_s).gsub(/\'|:/, "")
	version = ($os == 'darwin') ? (pack.to_s.match(/Version:.*/).to_s).gsub(/Version:/, "").strip : ((pack.match(/\'.*\',/)).to_s).gsub(/\'|,/, "")
    json_array.push({ "name" => name, "version" => version })
  end
  
  # return the list of all currently installed packages as a JSON object
  return JSON.generate({:packages => json_array})
end

##
#   Function used to backup a given file, both locally
#   and remotely on the server.
#
#   @param file: filepath to backup
##
def backup(file)

  backup_occured = facter_call(:backup_occured) rescue false
  msg = "No previous sum found locally or remotely on #{$fqdn}. Capturing fresh configuration."
	
  # send a warning
  backup_occured ? (Puppet.warning(msg) and $backup_occured = true) : (Puppet.info(msg) and $backup_occured = false)

  # capture and store the current config, both remotely and locally
  c = currentConfig()
  File.open(file, 'w') { |f| f.write(c)}

  filebucket_request(:local_backup, file: file)
  filebucket_request(:remote_backup, file: file)

  $backup_occured = false
end

##
#   Function used to restore a file from a checksum stored
#   on the server
#
#   @param file: filepath to restore
#   @return restored: returns true if restored successfully, false otherwise
##
def restore(file)

  # check the local system for a cached sum
  list = filebucket_request(:list)
  restored = false
  
  # if a sum is found locally
  unless list.nil? || list.empty?
    cached_files = list.split("\n")
  
    # search for the newest sum
    cached_files.reverse_each do |line|
      next if !(line.include? file) || restored
    
      # check to see if the sum exists on the server as well
      sum = line.split(" ")[0]		
      response = filebucket_request(:get, sum: sum)
    
      # if the sum exists AND the file has not yet been restored
      unless response.nil? || response.empty? || restored
                  
        # restore the file from the server and acknowledge
        restored = true
        filebucket_request(:restore, file: file, sum: sum)
        Puppet.notice("Restored #{file} from #{$server} (#{sum})")
      end	
    end
  
  # no local sum found, backup and send new config
  else
    backup file 
  end
  return restored
end

setup()
