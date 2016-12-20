##
#
#   Ruby script used alongside Puppet to retrieve
#   the initial configuration of a machine, store it
#   and use it as a baseline for configuration drift.
#
#   Alerts of any inconsistencies.
#
##

##
#		Function that searchs for, and alerts of,
#		any detected drift on the machine.
#
#		@return: yes if drift is found, no otherwise
##
def setup()

  # determine where to store facts based on the OS
  if $os.include? "windows"
    config_file = "C:/ProgramData/PuppetLabs/facter/facts.d/#{$fqdn}_configuration.yaml"
    $drift = "C:/ProgramData/PuppetLabs/facter/facts.d/#{$fqdn}_drift.yaml"
		$back = "C:/ProgramData/PuppetLabs/facter/facts.d/#{$fqdn}_back.yaml"
  else
    config_file = "/opt/puppetlabs/facter/facts.d/#{$fqdn}_configuration.yaml"
    $drift = "/opt/puppetlabs/facter/facts.d/#{$fqdn}_drift.yaml"
    $back = "/opt/puppetlabs/facter/facts.d/#{$fqdn}_back.yaml"
	end

  # if the file does not exist
  unless File.exist? config_file
		
		# if the file is never restored, a cached sum did not exist
		unless restore config_file
			# backup the current config as the new standard
			backup config_file
		end
		
  # otherwise, a configuration file exists, check for inconsistency
	else

		# retrieve the local sum of the file
		sum = Digest::MD5.file config_file
		
		# attempt to retrieve that sum from the server
		cmd = `puppet filebucket get #{sum} --server #{$server}`

		# if the sum is not returned, it did not exist
		if(cmd.nil? || cmd.empty?)

			# delete the local file and attempt to restore another sum
			File.delete config_file
			File.delete	$drift 
			if restore config_file
				Puppet.err("File found locally but not remotely. Restoring from cached copy.")

			# if a sum is not restored
			else
				# backup the current config and set it as the new standard
				backup config_file 
			end	
			return 'yes'
		end

    # retrieve the current config
    found_packages =  $current 
    
		# retrieve the saved config
		init_config = Facter.value(:configuration)
  	prev_drift = Facter.value(:drift) 
		drift = false
    
		# used to capture the current drift of the system
		$curr_drift = ""

		# if the saved config and current config match exactly
    if found_packages.gsub(" ", "").gsub("\n", "") == init_config.gsub(" ", "").gsub("\n", "")
      
      # send a notice and return
      Puppet.notice ("No drift detected on #{$fqdn}. (#{$time})")
      return 'no'

    # otherwise drift is detected
	 	else

      # prepare strings for comparision
      found_packages.gsub!("|", "")
      init_config.gsub!("|", "\n")
      init_config.gsub!("\"", "")
			found_packages.force_encoding 'utf-8'
			init_config.force_encoding 'utf-8'

			# array used to ignore duplicate inconsistancies
			ignore = Array.new

			# look for packages that are in the saved config
      # but not the current config
      init_config.each_line do |line|
        next if line.nil? || line.empty? || (line.include? "configuration")
        line.strip!
				
				# if a package is not found
				unless found_packages[line]				
					drift = true
					name = line.split("~")
					
					# version info not separated by ~, try spaces
					if(name.length == 1)
						length = line.split(" ").length
						name = line.split(" ")[0..length - 1].to_s
						ver = line.split(" ").last
					else
						name = line.split("~")[0]
						ver = line.split("~")[1]
					end

					# see if the package exists as a different version
					if found_packages.include? name
						
						# retrieve all of the version information
						str = ""
						
						# search the found packages		
						found_packages.each_line do |pack|
							# if the package is found, retrieve its version info
							if pack.include? name
								str = pack.strip!
								str.gsub!("~", " ")
							end
						end

						# alert if version differences
						notice = "#{name} #{ver} should be installed.\n        #{str} found."
						Puppet.notice(notice)

						# add the drift to the current drift
						unless($curr_drift.include? notice)
							$curr_drift += notice
						end
						
						ignore.push(name)

					# the package was uninstalled
					else
				 		line.gsub!("~", " ")	

         		notice = "#{line} not found on #{$fqdn}."
         		Puppet.notice(notice)
						
						unless($curr_drift.include? notice)
							$curr_drift += notice
						end
					end
				end
      end
			
      # look for packages installed after the saved config
      found_packages.each_line do |pack|
				name = pack.split("~")[0]
        next if pack.nil? || pack.empty? || (ignore.include? name)
        pack.strip!

        # if a package was installed after the config was captured
        unless init_config.include? pack
				 	pack.gsub!("~", " ")	
					drift = true
          notice = "#{pack} installed on #{$fqdn} after initial configuration."
          Puppet.notice(notice)
					
					unless($curr_drift.include? notice)
						$curr_drift += notice
					end
        end
      end
		
			if drift
				
				# capture the previous drift and if it differs from the current drift
				# send an error alert (goes to email)
				prev_drift = Facter.value(:drift)
				unless (prev_drift.gsub("\n", "").gsub(" ", "") == $curr_drift.gsub("\n", "").gsub(" ", ""))
					Puppet.err("Drift detected on #{$fqdn}. (#{$time})")

				# otherwise, an email has already been sent, just send a warning
				else
					Puppet.warning("Drift detected on #{$fqdn}. (#{$time})")
				end
     		return 'yes'

			# there is no drift
			else
      	Puppet.notice ("No drift detected on #{$fqdn}. (#{$time})")
				return 'no'
			end
   	end
	end
end

##
#	Function that retrieves the current state of the
#	the system and returns it as a string.
#
#	@return str: the current configuration of the machine
##
def currentConfig()

    # retrieve the current configuration
    cmd = `puppet resource package`
    packages = cmd.split("package")
    str = ""

		ip = Facter.value(:ipaddress)
		mac = Facter.value(:macaddress)
  
		# cycle through the found packages
    packages.each do |pack|
      next if pack.nil? || pack.empty?
      
      # try to retrieve version info
      version = pack.split("[")[1]
      if version.nil? || version.empty?
        version = pack.split("'")[3]
      else
        version = version.split("]")[0]
      end

      if version.nil? || version.empty?
        version = ""
      end

      # retrieve the name of the package
      name = pack.split("'")[1]

			# if version is separate add a ~ for easy separation later
			unless name.include? version
	      package = name + "~" + version
			else

				# otherwise, separate the version info 
				if !name.nil? and !name.empty?
					length = name.split(" ").length
					if length > 1 
						ver = name.split(" ").last
						name = name.split(" ")[0..length - 2].join(" ")
						package = name + "~" + ver
					end
				end
			end

      # if the package is currently installed
      # add it to the string to return
      unless package.nil? or package.include? "ensure" or package.empty? or (package.length < 2)
        str += "\n#{package}|"
      end
    end

		# append the ip and mac addresses to the configuration
		str += "\nip~#{ip}|" unless ip.nil?
		str += "\nmac~#{mac}|" unless mac.nil?

    # return the list of all currently installed packages
    return str
end

##
#		Function used to backup a given file, both locally
#		and remotely on the server.
#
#		@param file: filepath to backup
##
def backup(file)
	
	test = Facter.value(:backup_occured)
	
	# send a warning
	if (test.nil? || test == false)
		Puppet.err("No previous sum found locally or remotely on #{$fqdn}. Capturing fresh configuration.")
				
		# capture and store the current config, both remotely and locally
 		File.open(file, 'w') { |f| f.write("configuration: \"#{$current}\"") }
 		cmd = `puppet filebucket backup #{file} -l`  
 		cmd = `puppet filebucket backup #{file} --server #{$server}`
	
		$backup_occured = true
	else
		Puppet.notice("No previous sum found locally or remotely on #{$fqdn}. Capturing fresh configuration.")
		
		# capture and store the current config, both remotely and locally
 		File.open(file, 'w') { |f| f.write("configuration: \"#{$current}\"") }
 		cmd = `puppet filebucket backup #{file} -l`  
 		cmd = `puppet filebucket backup #{file} --server #{$server}`
	
		$backup_occured = false
	end
end

##
#		Function used to restore a file from a checksum stored
#		on the server
#
#		@param file: filepath to restore
#		@return restored: returns true if restored successfully, false otherwise
##
def restore(file)

	# check the local system for a cached sum
	cmd = `puppet filebucket -l list`
	restored = false
		
	# if a sum is found locally
	unless(cmd.nil? || cmd.empty?)
		test = cmd.split("\n")
		
		# search for the newest sum
		test.reverse_each do |line|
			next unless (line.include? file)
		
			# check to see if the sum exists on the server as well
			sum = line.split(" ")[0]		
			cmd = `puppet filebucket get #{sum} --server #{$server}`

			# if the sum exists AND the file has not yet been restored
			unless cmd.nil? || cmd.empty? || restored
					
				# restore the file from the server and acknowledge
				restored = true
				cmd = `puppet filebucket restore #{file} #{sum} --server #{$server}`
				Puppet.notice("Restored #{file} from #{$server} (#{sum})")
			end	
		end
	
	# no local sum found, backup and send new config
	else
		backup file 
	end

	return restored
end

$time = Time.now.utc
$os = Facter.value(:operatingsystem)
$fqdn = Facter.value(:fqdn)
$fqdn.downcase!
$current = currentConfig()
$server = "foreman.vai.org"
$backup_occured = false

# add a fact that can be used to check 
# for drift
Facter.add(:drift_detected) do
  setcode do

    # setup() returns yes if drift is found
    # and no otherwise
    d = setup()
		
		# create a fact to store the current system drift
		# used in alert system
		File.open($drift, 'w') { |f| f.write("drift: \"#{$curr_drift}\"") }
  
		File.open($back, 'w') { |f| f.write("backup_occured: \"#{$backup_occured}\"") }

	 	# Return yes if drift was found, no otherwise	
	 	"#{d}"
  end
end