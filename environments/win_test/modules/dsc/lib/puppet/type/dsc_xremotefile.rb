require 'pathname'

Puppet::Type.newtype(:dsc_xremotefile) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xRemoteFile resource type.
    Automatically generated from
    'xPSDesiredStateConfiguration/DSCResources/MSFT_xRemoteFile/MSFT_xRemoteFile.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_destinationpath is a required attribute') if self[:dsc_destinationpath].nil?
    end

  def dscmeta_resource_friendly_name; 'xRemoteFile' end
  def dscmeta_resource_name; 'MSFT_xRemoteFile' end
  def dscmeta_module_name; 'xPSDesiredStateConfiguration' end
  def dscmeta_module_version; '3.5.0.0' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    newvalue(:absent)  { provider.destroy }
    defaultto { :present }
  end

  # Name:         DestinationPath
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_destinationpath) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DestinationPath - Path under which downloaded or copied file should be accessible after operation."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Uri
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_uri) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Uri - Uri of a file which should be copied or downloaded. This parameter supports HTTP and HTTPS values."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UserAgent
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_useragent) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UserAgent - User agent for the web request."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Headers
  # Type:         MSFT_KeyValuePair[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_headers) do
    def mof_type; 'MSFT_KeyValuePair[]' end
    def mof_is_embedded?; true end
    desc "Headers - Headers of the web request."
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
    end
  end

  # Name:         Credential
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_credential) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "Credential - Specifies a user account that has permission to send the request."
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("Credential", value)
    end
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Present", "Absent"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - Says whether DestinationPath exists on the machine Valid values are Present, Absent."
    validate do |value|
      resource[:ensure] = value.downcase
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Present', 'present', 'Absent', 'absent'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Present, Absent")
      end
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_xremotefile).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
