require 'pathname'

Puppet::Type.newtype(:dsc_xscomreportingserversetup) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xSCOMReportingServerSetup resource type.
    Automatically generated from
    'xSCOM/DSCResources/MSFT_xSCOMReportingServerSetup/MSFT_xSCOMReportingServerSetup.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_ensure is a required attribute') if self[:dsc_ensure].nil?
    end

  def dscmeta_resource_friendly_name; 'xSCOMReportingServerSetup' end
  def dscmeta_resource_name; 'MSFT_xSCOMReportingServerSetup' end
  def dscmeta_module_name; 'xSCOM' end
  def dscmeta_module_version; '1.4.0.0' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    newvalue(:absent)  { provider.destroy }
    defaultto { :present }
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  True
  # Values:       ["Present", "Absent"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - An enumerated value that describes if the OM Reporting server is expected to be installed on the machine.\nPresent {default}  \nAbsent   \n Valid values are Present, Absent."
    isrequired
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

  # Name:         SourcePath
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sourcepath) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SourcePath - UNC path to the root of the source files for installation."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SourceFolder
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sourcefolder) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SourceFolder - Folder within the source path containing the source files for installation."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SetupCredential
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_setupcredential) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "SetupCredential - Credential to be used to perform the installation."
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("SetupCredential", value)
    end
  end

  # Name:         InstallPath
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_installpath) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "InstallPath - Installation path for the software."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ManagementServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_managementserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ManagementServer - The name of the management server associated with the Reporting server."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SRSInstance
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_srsinstance) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SRSInstance - The reporting server and instance."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         DataReader
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_datareader) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "DataReader - The domain and user name of the data reader account."
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("DataReader", value)
    end
  end

  # Name:         DataReaderUsername
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_datareaderusername) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "DataReaderUsername - Output username of the data reader account."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UseMicrosoftUpdate
  # Type:         uint8
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_usemicrosoftupdate) do
    def mof_type; 'uint8' end
    def mof_is_embedded?; false end
    desc "UseMicrosoftUpdate - 0: Do not opt in to Microsoft Update. 1: Opt in to Microsoft Update."
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         SendCEIPReports
  # Type:         uint8
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sendceipreports) do
    def mof_type; 'uint8' end
    def mof_is_embedded?; false end
    desc "SendCEIPReports - 0: Do not opt in to the Customer Experience Improvement Program (CEIP). 1: Opt in to CEIP."
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         EnableErrorReporting
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Never", "Queued", "Always"]
  newparam(:dsc_enableerrorreporting) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "EnableErrorReporting - Never: Do not opt in to sending automatic error reports. Queued: Opt in to sending error reports, but queue the reports for review before sending. Always: Opt in to automatically send error reports. Valid values are Never, Queued, Always."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['Never', 'never', 'Queued', 'queued', 'Always', 'always'].include?(value)
        fail("Invalid value '#{value}'. Valid values are Never, Queued, Always")
      end
    end
  end

  # Name:         SendODRReports
  # Type:         uint8
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sendodrreports) do
    def mof_type; 'uint8' end
    def mof_is_embedded?; false end
    desc "SendODRReports - 0: Do not opt in to sending operational data reports. 1: opt in to sending operational data reports."
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_xscomreportingserversetup).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
