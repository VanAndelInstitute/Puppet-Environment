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
  #


  # Important variables
  time = Time.now
  time = time.strftime("%Y%m%d%H%M%S")
  $polfile_copy = "c:\\windows\\temp\\Registry-#{time}.pol"
  $polfile_orig = 'c:\Windows\sysnative\GroupPolicy\Machine\Registry.pol'

  mk_resource_methods

  def initalize(value={})
    super(value)
    @property_flush = {}

  end

  def exists?
    @property_hash[:ensure] == :present
  end


  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    get_policy_settings
  end

  def self.get_policy_settings
    
    # Verify if files exist before moving on 
     instances = []
     settings_lookup = build_settings_lookup # [tShort, policyText, policyID, key, valueName, templateName]
     settings = []
        settings = get_current_settings
     curr_settings = []
     settings.each do |reg_key, reg_val, reg_typ, reg_siz, reg_dat|
        #puts "Testing: #{reg_key}, #{reg_val}"
        setting_ary = settings_lookup.select { |s| s.include? reg_val and s.include? "#{reg_key}" }
        setting = setting_ary[0]
        tShort = setting[0]
        policyText = setting[1]
        policyID = setting[2]
        setting_key = setting[3]
        setting_val = setting[4]
        templateName = setting[5]
        curr_settings << [tShort, policyText, policyID, templateName, reg_key, reg_val, reg_dat, reg_typ ]

     end
     lgp = curr_settings.group_by {|e| e[2]}
     lgp.each do |key,array|
        # Default variables
        dDir = 'C:\Windows\PolicyDefinitions'
        eDir = 'C:\Windows\PolicyDefinitions\en-US'
        dFile = REXML::Document.new( File.new("#{dDir}\\#{array[0][0]}.admx"))
        eFile = REXML::Document.new( File.new("#{eDir}\\#{array[0][0]}.adml"))
        droot = dFile.root
        eroot = eFile.root
        settings_hash = mapPolicies( droot, eroot, key)[array[0][1]][:policy_settings]
        settings_hash.each do |key,hash|
          setting_value = curr_settings.select { |x| x.include? hash[:settingKey] and x.include? hash[:settingValue]}
          if setting_value != []
            setting_value = setting_value[0][6]
            settings_hash[key] = setting_value

          else
            settings_hash.delete(key)
          end

        end

        attributes_hash = {:name => array[0][1], :ensure => :present, :policy_template => array[0][3], :policy_settings => settings_hash }
        instances << new(attributes_hash)

     end
     instances
  end


  def update_policy
    
    log = Logger::new('c:\windows\temp\debug.txt')
    log.debug "Starting Debug of policy update"

    #Variables
    policy_settings = []

    settings = []
    dDir = 'C:\Windows\PolicyDefinitions'
    eDir = 'C:\Windows\PolicyDefinitions\en-US'


    #Set up output file  (Copy Registry.pol to c:\Windows\Temp
    #time = Time.now
    #time = time.strftime("%Y%m%d%H%M%S")

    # Gather info that is needed
    set_policy_name = resource[:name]
    set_policy_template = resource[:policy_template]
    set_policy_setting = resource[:policy_settings]
    log.debug "#{set_policy_name}, #{set_policy_template}, #{set_policy_setting}\n"

    # Collect current settings and merge settings
    #Break down current Registry.pol
    existing_settings = self.class.get_current_settings
    #Find matching policies
    settings_lookup = self.class.build_settings_lookup # [tShort, policyText, policyID, key, valueName, templateName]
    #Compare and add required information
    curr_settings = []
    existing_settings.each do |ex_reg_key, ex_reg_val, ex_reg_typ, ex_reg_siz, ex_reg_dat|
      sys_settings = settings_lookup.select { |s| s.include? ex_reg_val and s.include? "#{ex_reg_key}" }
      #log.debug "Registry Type: #{ex_reg_typ} Registry_data: #{ex_reg_dat}"
      sys_tShort = sys_settings[0][0]
      sys_policyText = sys_settings[0][1]
      sys_policyID = sys_settings[0][1]
      sys_templateName = sys_settings[0][5]
      #log.debug ex_reg_typ
      ex_reg_typ = self.class.reg_type_conv_pol_rev(ex_reg_typ)
      curr_settings << [ sys_tShort, sys_policyText, sys_policyID, sys_templateName, ex_reg_key, ex_reg_val, ex_reg_dat, ex_reg_typ ]
    end
    exist_settings_hash = curr_settings.group_by { |e| e[1] }
    exist_settings_hash.each do |key,value|
      if key != set_policy_name
        #log.debug value
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
    sys_tShort = policy_search[0][0]


    dFile = REXML::Document.new( File.new("#{dDir}\\#{sys_tShort}.admx"))
    eFile = REXML::Document.new( File.new("#{eDir}\\#{sys_tShort}.adml"))
    droot = dFile.root
    eroot = eFile.root

    #Look up enabled values
#log.debug "Policy Name: #{sys_tShort}"
#log.debug "PolicyID: #{sys_policyID}"
    policy_def = self.class.mapPolicies(droot,eroot, sys_policyID)
#    log.debug policy_def.to_s
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

      log.debug "#{settings}\n"
    end

    # Write file
    polfile = File.open($polfile_orig, 'wb:UTF-8')
    polfile.write "\x50\x52\x65\x67\x01\x00\x00\x00"
    settings.each do |key,val,typ,size, dat|
      polfile.write "[#{key};#{val};#{typ};#{size};#{dat}]\x00"
    end

    polfile.close

  end

  def conv_to_write_ary ( orig_key, orig_val, orig_typ, orig_dat )

    log = Logger::new('c:\windows\temp\debug.txt')

    reg_key = value_buffer(orig_key)
    reg_val = value_buffer(orig_val)
    reg_typ = self.class.reg_type_conv_pol_rev(orig_typ).encode('UTF-8')
    if reg_typ == "\u0001"
      reg_dat = orig_dat.encode('UTF-8')
    else
      #log.debug "#{orig_dat} : #{orig_dat.encoding.name}"
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
  def value_buffer (value)
    value = value + "\x00"
    value = "\x00" + value.gsub(/(.)/,'\1'+"\x00")
    value
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

  # GPO Definitions
  #
  def self.mapPolicyStrings (eroot)
    policyString = {}
    eroot.each_element('resources/stringTable/string') do |ele|
      policyString[ele.attributes['id']] = ele.text
    end
    policyString
  end

  def self.mapPolicies ( droot, eroot, policyID)
    log = Logger::new('c:\windows\temp\debug.txt')

	@policyString = mapPolicyStrings(eroot)
	#log.debug @policyString
	policy = {}
	policyName = ""
	#Map a policies
	droot.each_element("//policies/policy[@name=\"#{policyID}\"]") do |policyElement|

		policyID = policyElement.attributes["name"]
		policyName = @policyString[policyElement.attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']

		#log.debug policyName
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
	droot.each_element("//policy[@name=\"#{policyID}\"]/elements/*") do |policySettingElement|
		pSettingRefId = policySettingElement.attributes["id"]
		setelepresentation = eroot.elements["//presentation/*[@refId=\"#{pSettingRefId}\"]"]

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
			pSettingKey = droot.elements["//policy[@name=\"#{policyID}\"]"].attributes["key"]
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

  def self.unbuffer_value(value)
    value = value.gsub(/(.)\x00/,'\1').gsub(/^\x00(.*)\x00$/,'\1')
    value
  end

  def self.get_current_settings

  #origfile = 'c:\Windows\sysnative\GroupPolicy\Machine\Registry.pol'
    #puts "File #{$polfile_orig}***********"
    #tempfile = 'c:\Windows\Temp\RegistryMachineBak.pol'
    
    polfile = File.open($polfile_orig,'rb:UTF-8').read
    lineary = polfile.split("]\x00[")
    
    #clean first and last lines
    lineary[0] = lineary[0].gsub!(/.*\[/,'')
    lastindex = lineary.length - 1
    lineary[lastindex] = lineary[lastindex].gsub!(/\].*/,'')

	regary = []

	lineary.each do |line|
        entry = line.split(";")
        reg_key = unbuffer_value(entry[0])
        reg_val = unbuffer_value(entry[1])
        reg_typ = reg_type_conv_pol(unbuffer_value(entry[2]))
        reg_siz = unbuffer_value(entry[3])
        reg_dat = unbuffer_value(entry[4])
        #TODO: Fix this to handle del lines
        if ! reg_val.include? "**del."
            regary << [ reg_key, reg_val, reg_typ, reg_siz, reg_dat ]
            #puts regary
        end
	end

	regary

  end


# Defin: build_settings_lookup
# Output: [policyFileName, policyText, policyID, key, valueName]
  def self.build_settings_lookup

	settings_lookup = []

	# Default variables
	dDir = 'C:\Windows\PolicyDefinitions'
	eDir = 'C:\Windows\PolicyDefinitions\en-US'


	Dir.entries(dDir).each do |file|
		tShort = file.gsub /(\w+)\.admx/, '\1'
		if tShort != '.' and tShort != '..' and tShort != 'en-US'
			dFile = REXML::Document.new( File.new("#{dDir}\\#{tShort}.admx"))
			eFile = REXML::Document.new( File.new("#{eDir}\\#{tShort}.adml"))

			droot = dFile.root
			eroot = eFile.root

			policyString = mapPolicyStrings(eroot)

            if droot.elements['//categories/category[1]']
                templateName = policyString[droot.elements['//categories/category[1]'].attributes["displayName"].gsub /^\$\(\w+\.(\w+)\)/, '\1']
			else
                templateName = "UNK for #{tShort}"
            end
			droot.each_element('//policy') do |policy|
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
					settings_lookup << [ tShort, policyText, policyID, key, valueName, templateName]
				end
				policy.each_element('elements/*') do |policy_element|
					valueName = policy_element.attributes["valueName"]
					if valueName != nil and key != nil
						#puts key + "," + valueName
						#key.gsub!(/\\\\/,"\\")
						key = parentKey
						settings_lookup << [tShort, policyText, policyID, key, valueName, templateName]
						#puts settings_lookup
					end
				end
			end
		end
	end
	settings_lookup
  end

def self.reg_type_conv_pol_rev (type_setting)
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
