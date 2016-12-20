Puppet::Type.type(:local_group_policy).provide(:group_policy) do
  require 'rexml/document'
  require 'logger'
  #Look at yumrepo/inifile.rb
  #
  #TODO
  #Destroy module
  # Overwight GPO?
  # Helper to lookup values
  # Better handle of delete instances **del.
  # Add additional provider to update policy
  # Template name uses parentName.   Need to update this to do full pathing (Not sure its worth it)
  
  # This provider is designed to set and get resources for the Windows Local Global Policy Templates
  # Microsoft uses two areas to define and set the global policy
  # 1) The Definitions that make up the gpedit tool are found in C:\Windows\PolicyDefinitions
  # Variables that are relate to dealing with this section are:
  ## definitions_dir => Primary directory for gpo 
  ## definitions_strings_dir => Strings for the gpo definitions
  #
  # 2) The output of gpedit is saved in the C:\Windows\System32\GroupPolicy directory with the following structure
  ## /GroupPolicy
  ## \-> /Machine
  ##     \-> /Scripts
  ##         \-> /Startup
  ##         \-> /Shutdown
  ##     \-> Registry.pol   
  ## \-> /User
  ##     \-> Registry.pol   
  ## \-> gpt.ini
  # Variables that are related to this section are:
  ## polfile => Active policy file 
  ## polfile_copy => A time based backup of the registry in case something goes wrong
  ## polfile_directory => The root directory of the policy settings
  ## polfile_cur_settings => The current settings of the policy files
  # 
  # Registry.pol files are key.  They are binary files stored in a very specific format.  
  # This file is broken down into the following fields
  # registry key, registry value, registry type, registry data size (binary * 2), registry data
  # Variables in this code
  ## polfile_setting_key => Registry Key Field
  ## polfile_setting_value => Registry  value
  ## polfile_setting_type => Registry Value Type (like DWORD)
  ## polfile_setting_size => The binary size of the data * 2
  ## polfile_setting_data => The data of the Registry Value
  #
  
  # Global variables
  $DEBUG = true
  time = Time.now
  time = time.strftime("%Y%m%d%H%M%S")
  $polfile_copy = "c:\\windows\\temp\\Registry-#{time}.pol"
  $polfile_directory = 'c:\Windows\sysnative\GroupPolicy'
  $polfile_machine = "#{$polfile_directory}\\Machine\\Registry.pol"
  $polfile_user = "#{$polfile_directory}\\User\\Registry.pol"
    
  $definitions_dir= 'C:\Windows\PolicyDefinitions'
  $definitions_strings_dir = "#{$definitions_dir}\\en-US"
  
  # Open a log file to write to for debugging info
  $log = Logger::new('c:\windows\temp\lgp_puppet_debug.txt')
      

  ################################
  # This block is setup to call the puppet calls for create destroy and lookup methods
  mk_resource_methods

  def initalize(value={})
  # The @property_flush variable is necessary for the provider to destroy, or
  # ensure absent, the instance. All other initialization can be left to the
  # parent classes
    super(value)
    @property_flush = {}
  end

  def exists?
    @property_hash[:ensure] == :present
  end
  
  def flush
    update_policy
  end

  def create
    @property_flush[:ensure] == :present
  end

  def destroy
    #Destroy not an option for now.  LSP Settings should be set to something.
  end

  ################################
  def self.instances
    # self.instances returns all instances of the resource type that are
    # discovered on the system.  The self.instances method is used by `puppet
    # resource`, and MUST be implemented for `puppet resource` to work. The
    # self.instances method is also frequently used by self.prefetch (which is
    # also the case for this provider class).
    get_policy
  end
    
  def self.prefetch(resources)
  # Prefetching is invoked when managing a resource with `puppet agent`,
   # `puppet apply`, or using `puppet resource` to change a resource from the
   # command line. The self.prefetch method accepts a hash of all managed
   # resources for the mac proxy types (i.e. all resources of this type that
   # are in the catalog). The method also populates the @property_hash instance
   # variable with property values for each managed resource, and
   # @property_hash can be used by all provider methods (i.e. all methods that
   # DON'T begin with 'self.'). In this case (as is the case with most
   # prefetching methods), we're using self.instances to discover all property
   # values.
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end
  
  ############################################
  # Non-puppet specific functions
  
  def self.get_current_settings
  # Get Current Settings will review the current global policy and parse the files for 
  # settings that have already been added to the system
    
    polfile_cur_settings = [] # Used to keep a list of all the current global policy settings
    
    $log.debug "Checking for existence of current registry settings:  #{$polfile_machine}" if $DEBUG 
    if File.exist?($polfile_machine)
    # Verify that the policy file exist before trying to open it
      # Open up the policy files for reading
      polfile = File.open($polfile_machine,'rb:UTF-8').read
      current_policy_settings = polfile.split("]\x00[")
      
      #clean first and last lines from the polfile
      current_policy_settings[0] = current_policy_settings[0].gsub!(/.*\[/,'')
      lastindex = current_policy_settings.length - 1
      current_policy_settings[lastindex] = current_policy_settings[lastindex].gsub!(/\].*/,'')
      
      
      # read in the policy file and break it up
      current_policy_settings.each do |line|
        entry = line.split(";")
        pol_setting_key = unbuffer_value(entry[0])                      # Policy Registry Key
        pol_setting_value = unbuffer_value(entry[1])                    # Policy Registry Value
        pol_setting_type = reg_type_conv_pol(unbuffer_value(entry[2]))  # Policy Registry Type
        pol_setting_size = unbuffer_value(entry[3])                     # Policy Registry Size (the binary size of the data)
        pol_setting_data = unbuffer_value(entry[4])                     # Policy Registry Data
        
        #TODO: Fix this to handle del lines  for now we are going to ignore any deletes 
        # deletes are put in to ensure that the registry keys are completely deleted
        if ! pol_setting_value.include? "**del."
        
          polfile_cur_settings << [ pol_setting_key, pol_setting_value, pol_setting_type, pol_setting_size, pol_setting_data ]
          $log.debug "Found setting: #{polfile_cur_settings}" if $DEBUG
          #puts polfile_cur_settings_ary
        end
      end
    end
    
    #Return value of polfile_cur_settings
    polfile_cur_settings
  
  end
  def self.get_policy
     $log.debug "Getting all instances of current policies"
     instances = []     #Instances of current policy settings
     curr_policy_settings = []   #All current policy settings in registry.pol files
       
     #First we need to build an entire list of possible settings that microsoft has
     # TODO: Need to simplify this part so that it does less work
     #settings_lookup = build_settings_lookup # [definition_template_shortname, policyText, policyID, key, valueName, templateName]
     # Then we need to get list of current settings out of policy files
     cur_settings_read = get_current_settings # policyKey, policy_Value, policyType, policy_Size, policy_Data
     
    #Search through current settings, then look it up in microsoft definitions.  
     # Add additional lookup information to curr_policy_settings array
    cur_settings_read.each do |reg_key, reg_val, reg_typ, reg_siz, reg_dat|
        $log.debug "GetPolicy Reading setting: #{reg_key}, #{reg_val}"
        #setting_ary = settings_lookup.select { |s| s.include? reg_val and s.include? "#{reg_key}" }
        setting_ary = policy_settings_lookup("#{reg_key}",reg_val)
        setting = setting_ary[0]
        definition_template_shortname = setting[0]
        policyText = setting[1]
        policyID = setting[2]
        setting_key = setting[3]
        setting_val = setting[4]
        templateName = setting[5]
        curr_policy_settings << [definition_template_shortname, policyText, policyID, templateName, reg_key, reg_val, reg_dat, reg_typ ]

     end
     
     #Group and lookup additional information about the policy.  This section will add human readable language based on the keys
     # lgp is an array of all policies grouped by policyID
     lgp = curr_policy_settings.group_by {|e| e[2]} 
     lgp.each do |key,lgp_entry|
        # Default variables
       definitions_file = REXML::Document.new( File.new("#{$definitions_dir}\\#{lgp_entry[0][0]}.admx"))
       defintions_strings_file = REXML::Document.new( File.new("#{$definitions_strings_dir}\\#{lgp_entry[0][0]}.adml"))
       definitions_file_xml = definitions_file.root
       definitions_strings_xml = defintions_strings_file.root

        settings_hash = mapPolicies( definitions_file_xml, definitions_strings_xml, key)[lgp_entry[0][1]][:policy_settings]
        settings_hash.each do |key,hash|
          setting_value = curr_policy_settings.select { |x| x.include? hash[:settingKey] and x.include? hash[:settingValue]}
          if setting_value != []
            setting_value = setting_value[0][6]
            settings_hash[key] = setting_value

          else
            settings_hash.delete(key)
          end

        end

        attributes_hash = {:name => lgp_entry[0][1], :ensure => :present, :policy_settings => settings_hash }
        instances << new(attributes_hash)

     end
     instances
  end

  def update_policy
  # Update policy is used to update the policy file based on the puppet type definition
    
    $log.debug "Starting Debug of policy update" if $DEBUG
    
    # Build directory structure if it does not exist
    


    #Set up output file  (Copy Registry.pol to c:\Windows\Temp
    #time = Time.now
    #time = time.strftime("%Y%m%d%H%M%S")

    # Gather info that is needed
    set_policy_name = resource[:name]
    set_policy_setting = resource[:policy_settings]
    $log.debug "Update Policy Setting: #{set_policy_name}, #{set_policy_setting}" if $DEBUG

    # Collect current settings and merge settings
    #Break down current Registry.pol
    existing_settings = self.class.get_current_settings
    #Find matching policies
    settings_lookup = self.class.build_settings_lookup # [definition_template_shortname, policyText, policyID, key, valueName, templateName]
    #Compare and add required information
    curr_settings = []
    existing_settings.each do |ex_reg_key, ex_reg_val, ex_reg_typ, ex_reg_siz, ex_reg_dat|
      sys_settings = settings_lookup.select { |s| s.include? ex_reg_val and s.include? "#{ex_reg_key}" }
      $log.debug "Registry Type: #{ex_reg_typ} Registry_data: #{ex_reg_dat}" if $DEBUG
      sys_definition_template_shortname = sys_settings[0][0]
      sys_policyText = sys_settings[0][1]
      sys_policyID = sys_settings[0][1]
      sys_templateName = sys_settings[0][5]
      $log.debug "Update Policy: #{ex_reg_typ}" if $DEBUG
      ex_reg_typ = self.class.reg_type_conv_pol_rev(ex_reg_typ)
      curr_settings << [ sys_definition_template_shortname, sys_policyText, sys_policyID, sys_templateName, ex_reg_key, ex_reg_val, ex_reg_dat, ex_reg_typ ]
    end
    exist_settings_hash = curr_settings.group_by { |e| e[1] }
    exist_settings_hash.each do |key,value|
      if key != set_policy_name
        $log.debug "Update Policy Value: #{value}" if $DEBUG
        value.each do |setting|
          settings << conv_to_write_ary( setting[4] , setting[5] ,setting[7] ,setting[6] )
        end
      else
        exist_settings_hash.delete(key)
      end
    end

    #Find info on new setting
    policy_search = settings_lookup.select { |s| s.include? set_policy_name }
    sys_policyID = policy_search[0][2]
    sys_definition_template_shortname = policy_search[0][0]


    definitions_file = REXML::Document.new( File.new("#{$definitions_dir}\\#{sys_definition_template_shortname}.admx"))
    defintions_strings_file = REXML::Document.new( File.new("#{$definitions_strings_dir}\\#{sys_definition_template_shortname}.adml"))
    definitions_file_xml = definitions_file.root
    definitions_strings_xml = defintions_strings_file.root

    #Look up enabled values
    $log.debug "Policy Name: #{sys_definition_template_shortname}" if $DEBUG
    $log.debug "PolicyID: #{sys_policyID}" if $DEBUG
    policy_def = self.class.mapPolicies(definitions_file_xml,definitions_strings_xml, sys_policyID)
    $log.debug "Policy Definition: #{policy_def.to_s}" if $DEBUG
    policy_def.each do |policy_name,policy_details|
      settings << conv_to_write_ary(policy_details[:policyEnable][:enableKey], policy_details[:policyEnable][:policyEnableValueName], policy_details[:policyEnable][:enableType],policy_details[:policyEnable][:enableSetting])
      #All policy settings
      policy_details[:policy_settings].each do |key,value|
        sys_name = key
        sys_key = value[:settingKey]
        sys_val = value[:settingValue]
        sys_typ = value[:settingType]
        sys_dat = value[:settingDefault]
        sys_req = value[:settingRequired]
        include_setting = false
        if sys_req == 'true'
          include_setting = true
        end
        set_policy_setting.each do |key,value|
          if key == sys_name
            include_setting = true
            sys_dat = value
          end
        end
        if include_setting
          settings << conv_to_write_ary(sys_key, sys_val, sys_typ, sys_dat )
        end
      end

        #Look up settings values
      #policy_setting_def = mapPolicy

      $log.debug "Update Policy Setting: #{settings}" if $DEBUG
    end

    # Write file
    polfile = File.open($polfile_machine, 'wb:UTF-8')
    polfile.write "\x50\x52\x65\x67\x01\x00\x00\x00"
    settings.each do |key,val,typ,size, dat|
      polfile.write "[#{key};#{val};#{typ};#{size};#{dat}]\x00"
    end

    polfile.close

  end


  # GPO Definitions
  #
  def self.mapPolicyStrings (definitions_strings_xml)
    policyString = {}
    definitions_strings_xml.each_element('resources/stringTable/string') do |ele|
      policyString[ele.attributes['id']] = ele.text
    end
    policyString
  end

  def self.mapPolicies ( definitions_file_xml, definitions_strings_xml, policyID)
   
	@policyString = mapPolicyStrings(definitions_strings_xml)
	$log.debug "All Policies Strings (mapPolicy): #{@policyString}" if $DEBUG
	policy = {}
	policyName = ""
	#Map a policies
	definitions_file_xml.each_element("//policies/policy[@name=\"#{policyID}\"]") do |policyElement|

		policyID = policyElement.attributes["name"]
		policyName = @policyString[policyElement.attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']

		$log.debug "Lookup for policyID (#{policyID}): #{policyName}" if $DEBUG
		#Set up policy hash
		#policy[policyName] = { :policyID => policyID }

		#policy[policyName].merge!( :nameSpace => nameSpace)

    policy[policyName] = {}
		policy[policyName].merge!( :policyClass     => policyElement.attributes["class"] )
		#policy[policyName].merge!( :policyParentKey => policyElement.attributes["key"] )
		policyEnableValueName = policyElement.attributes["valueName"]
		# Set enabled info
		policyEnableElement = policyElement.elements["enabledValue[1]/*"] || policyElement.elements["enabledList[1]/*"]
		if policyEnableElement != nil
			if policyEnableElement.name != "item"
				policyEnableType = reg_type_conv_xml(policyEnableElement.name)
				policyEnableValue = policyEnableElement.attributes["value"]
				policyEnableKey = policy[policyName][:policyParentKey]
            else
				policyEnableKey = policyEnableElement.attributes["key"]
				policyEnableValueName = policyEnableElement.attributes["valueName"]
				policyEnableItemElement = policyEnableElement.elements['value[1]/*']
				policyEnableType = reg_type_conv_xml(policyEnableItemElement.name)
				policyEnableValue = policyEnableItemElement.attributes["value"]
			end
			policy[policyName].merge!( :policyEnable => { :enableKey => policyEnableKey, :policyEnableValueName => policyEnableValueName, :enableSetting =>  policyEnableValue, :enableType => policyEnableType} )
		end

	end
	# Now go get all settings for each policy, if there are any
	policySettings = {}
	definitions_file_xml.each_element("//policy[@name=\"#{policyID}\"]/elements/*") do |policySettingElement|
		pSettingRefId = policySettingElement.attributes["id"]
		setelepresentation = definitions_strings_xml.elements["//presentation/*[@refId=\"#{pSettingRefId}\"]"]

		# Set each Setting : Text String
		pSettingText = ""
		if setelepresentation.elements['label'] != nil
			pSettingText = setelepresentation.elements['label'].text
            else
			pSettingText = setelepresentation.text
		end
		# Set up policySetting Hash
		policySettings[pSettingText] = {}


		# Check for a different key for setting or set to parent
		pSettingKey = ""
		if policySettingElement.attributes["key"]
			pSettingKey = policySettingElement.attributes["key"]
            else
			pSettingKey = definitions_file_xml.elements["//policy[@name=\"#{policyID}\"]"].attributes["key"]
		end
		policySettings[pSettingText].merge!( :settingKey => pSettingKey )

		# Set each Setting : Registry Value String
		policySettings[pSettingText].merge!( :settingValue => policySettingElement.attributes["valueName"] )

		# Set each Setting : Registry Type
		pSettingType = ""
		if pSettingType == "enum"
			option = policySettingElement.elements["item/value[1]/*"].name
            else
			pSettingType = policySettingElement.name
		end
		policySettings[pSettingText].merge!( :settingType => reg_type_conv_xml(pSettingType) )

		# Set each Setting : Default Reg Value Setting and if its required
		if policySettingElement.attributes["required"]
			pSettingRequired = policySettingElement.attributes["required"]

			pSettingDefaultValue = setelepresentation.attributes["defaultChecked"] || setelepresentation.attributes["defaultItem"] || setelepresentation.attributes["defaultValue"]
			if pSettingDefaultValue == "true"
				pSettingDefaultValue = 1
                elsif pSettingDefaultValue == "false"
				pSettingDefaultValue = 0
                elsif pSettingDefaultValue == nil
				pSettingDefaultValue = ""
			end
			policySettings[pSettingText].merge!(:settingRequired => pSettingRequired, :settingDefault => pSettingDefaultValue)
            else
			policySettings[pSettingText].merge!(:settingRequired => pSettingRequired)
		end
	end
	policy[policyName].merge!(:policy_settings => policySettings )
	policy
  end


# Defin: build_settings_lookup
# Output: [policyFileName, policyText, policyID, key, valueName]
  def self.build_settings_lookup

	settings_lookup = []


	Dir.entries($definitions_dir).each do |file|
		definition_template_shortname = file.gsub /(\w+)\.admx/, '\1'
		if definition_template_shortname != '.' and definition_template_shortname != '..' and definition_template_shortname != 'en-US'
			definitions_file = REXML::Document.new( File.new("#{$definitions_dir}\\#{definition_template_shortname}.admx"))
			defintions_strings_file = REXML::Document.new( File.new("#{$definitions_strings_dir}\\#{definition_template_shortname}.adml"))

			definitions_file_xml = definitions_file.root
			definitions_strings_xml = defintions_strings_file.root

			policyString = mapPolicyStrings(definitions_strings_xml)

      if definitions_file_xml.elements['//categories/category[1]']
          templateName = policyString[definitions_file_xml.elements['//categories/category[1]'].attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']
			else
          templateName = "Error: Unknown template name: #{definition_template_shortname}"
      end
			definitions_file_xml.each_element('//policy') do |policy|
				valueName = ""
				policyID = policy.attributes["name"]
				parentKey = policy.attributes["key"]
				policyText = policyString[policy.attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']
				if policy.elements['enabledList/item/*']
					valueName = policy.elements['enabledList[1]/item'].attributes["valueName"]
                    else
					valueName = policy.attributes["valueName"]
				end
				if policy.elements['enabledList/item/*']
					key = policy.elements['enabledList[1]/item'].attributes["key"]
                    else
					key = parentKey
				end
				if valueName != nil and key != nil
					#puts key + "," + valueName
					#key.gsub!(/\\+/,"\\")
					settings_lookup << [ definition_template_shortname, policyText, policyID, key, valueName, templateName]
				end
				policy.each_element('elements/*') do |policy_element|
					valueName = policy_element.attributes["valueName"]
					if valueName != nil and key != nil
						#puts key + "," + valueName
						#key.gsub!(/\\\\/,"\\")
						key = parentKey
						settings_lookup << [definition_template_shortname, policyText, policyID, key, valueName, templateName]
						#puts settings_lookup
					end
				end
			end
		end
	end
	settings_lookup
  end
  
def self.policy_settings_lookup (registry_key, registry_value)

  settings_lookup = []


  Dir.entries($definitions_dir).each do |file|
    definition_template_shortname = file.gsub /(\w+)\.admx/, '\1'
    if definition_template_shortname != '.' and definition_template_shortname != '..' and definition_template_shortname != 'en-US' and  File.readlines("#{$definitions_dir}\\#{definition_template_shortname}.admx").grep(/#{registry_value}/).any?
      definitions_file = REXML::Document.new( File.new("#{$definitions_dir}\\#{definition_template_shortname}.admx"))
      defintions_strings_file = REXML::Document.new( File.new("#{$definitions_strings_dir}\\#{definition_template_shortname}.adml"))

      definitions_file_xml = definitions_file.root
      definitions_strings_xml = defintions_strings_file.root

      policyString = mapPolicyStrings(definitions_strings_xml)

      #Try and discover the gpedit path - Currently does not always work
      if definitions_file_xml.elements['//categories/category[1]']
          templateName = policyString[definitions_file_xml.elements['//categories/category[1]'].attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']
      else
          templateName = "Error: Unknown template name: #{definition_template_shortname}"
      end
      definitions_file_xml.each_element('//policy') do |policy|
        valueName = ""
        policyID = policy.attributes["name"]
        parentKey = policy.attributes["key"]
        policyText = policyString[policy.attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']
        if policy.elements['enabledList/item/*']
          valueName = policy.elements['enabledList[1]/item'].attributes["valueName"]
                    else
          valueName = policy.attributes["valueName"]
        end
        if policy.elements['enabledList/item/*']
          key = policy.elements['enabledList[1]/item'].attributes["key"]
                    else
          key = parentKey
        end
        if valueName != nil and key != nil
          #puts key + "," + valueName
          #key.gsub!(/\\+/,"\\")
          settings_lookup << [ definition_template_shortname, policyText, policyID, key, valueName, templateName]
        end
        policy.each_element('elements/*') do |policy_element|
          valueName = policy_element.attributes["valueName"]
          if valueName != nil and key != nil
            #puts key + "," + valueName
            #key.gsub!(/\\\\/,"\\")
            key = parentKey
            settings_lookup << [definition_template_shortname, policyText, policyID, key, valueName, templateName]
            $log.debug "Lookup Array (#{definition_template_shortname}): #{settings_lookup}" if $DEBUG
          end
        end
      end
    end
  end
  settings_lookup
  
  end

###################
# All of the functions below are used to write/read the registry policy file registry.pol (binary file in microsoft format
  def conv_to_write_ary ( orig_key, orig_val, orig_typ, orig_dat )

    reg_key = value_buffer(orig_key)
    reg_val = value_buffer(orig_val)
    reg_typ = self.class.reg_type_conv_pol_rev(orig_typ).encode('UTF-8')
    if reg_typ == "\u0001"
      reg_dat = orig_dat.encode('UTF-8')
    else
      $log.debug "Conv_to_write_ary (show conversion): #{orig_dat} : #{orig_dat.encoding.name}" if $DEBUG
      if orig_dat[/\H/]
        reg_dat = orig_dat
      else
        reg_dat = Integer(orig_dat).chr.force_encoding('UTF-8')
      end
    end
    reg_siz = value_reg_siz(reg_dat)
    reg_dat = value_buffer(reg_dat)
    write_ary = [  reg_key , reg_val ,reg_typ ,reg_siz, reg_dat  ]
    write_ary
  end

  def value_reg_siz ( value )
  # Used as part of the registy.pol write.   All sizes for binary value must be calculated and insterted as part of each entry
    reg_siz = ((value.length + 1) * 2).chr
    if reg_siz.length == 1
      reg_siz = reg_siz + "\x00"
      reg_siz = "\x00" + reg_siz.gsub(/(.)/,'\1'+"\x00") + "\x00"
    else
      reg_siz = "\x00" + reg_siz.gsub(/(.)/,'\1'+"\x00") + "\x00"
    end
    #buffer with \x00
    reg_siz
  end
  
  def self.unbuffer_value(value)
    value = value.gsub(/(.)\x00/,'\1').gsub(/^\x00(.*)\x00$/,'\1')
    value
  end
  def value_buffer (value)
  #Used as part of the registry pol write to buffer every character with a \x00 line
    value = value + "\x00"
    value = "\x00" + value.gsub(/(.)/,'\1'+"\x00")
    value
  end
  def self.reg_type_conv_pol_rev (type_setting)
  # reg_type_conv_pol_rev    - Reverse conversion of the binary representation of the registry Types
    case type_setting
          when "REG_SZ"
      return "\u0001"
          when "REG_EXPAND_SZ"
      return "\u0002"
          when "REG_BINARY"
      return "\u0003"
          when "REG_DWORD"
      return "\u0004"
          when "REG_DWORD_BIG_ENDIAN"
      return "\u0005"
          when "REG_MULTI_SZ"
      return "\u0007"
          when "REG_QWORD"
      return "\u0008"
          else
      return type_setting
    end
  end

  def self.reg_type_conv_pol (type_setting)
    # reg_type_conv_pol    - Conversion of the binary representation of the registry Types
    case type_setting
        when "\u0001"
		return "REG_SZ"
        when "\u0002"
		return "REG_EXPAND_SZ"
        when "\u0003"
		return "REG_BINARY"
        when "\u0004"
		return "REG_DWORD"
        when "\u0005"
		return "REG_DWORD_BIG_ENDIAN"
        when "\u0007"
		return "REG_MULTI_SZ"
        when "\u0008"
		return "REG_QWORD"
        else
		return type_setting
	end
  end

  def self.reg_type_conv_xml ( type_name )
    case type_name
        when "decimal"
        return "REG_DWORD"
        when "text"
        return "REG_SZ"
        else
        return "UNK"
    end
  end
end
