require 'pathname'

Puppet::Type.newtype(:dsc_xscsmawebserviceserversetup) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xSCSMAWebServiceServerSetup resource type.
    Automatically generated from
    'xSCSMA/DSCResources/MSFT_xSCSMAWebServiceServerSetup/MSFT_xSCSMAWebServiceServerSetup.schema.mof'

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

  def dscmeta_resource_friendly_name; 'xSCSMAWebServiceServerSetup' end
  def dscmeta_resource_name; 'MSFT_xSCSMAWebServiceServerSetup' end
  def dscmeta_module_name; 'xSCSMA' end
  def dscmeta_module_version; '1.3.0.0' end

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
    desc "Ensure - An enumerated value that describes if the SMA Web Service server is expected to be installed on the machine.\nPresent {default}  \nAbsent   \n Valid values are Present, Absent."
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

  # Name:         FirstWebServiceServer
  # Type:         boolean
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_firstwebserviceserver) do
    def mof_type; 'boolean' end
    def mof_is_embedded?; false end
    desc "FirstWebServiceServer - Is this the first Management Server?"
    validate do |value|
    end
    newvalues(true, false)
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_boolean(value.to_s)
    end
  end

  # Name:         ApPool
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_appool) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "ApPool - Service account of the web service application pool."
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("ApPool", value)
    end
  end

  # Name:         ApPoolUsername
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_appoolusername) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ApPoolUsername - Output username of the web service application pool."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         AdminGroupMembers
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_admingroupmembers) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "AdminGroupMembers - A comma-separated list of users to add to the IIS Administrators group."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SqlServer
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sqlserver) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SqlServer - Name of the SQL Server for the SMA database."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SqlInstance
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sqlinstance) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SqlInstance - Name of the SQL Instance for the SMA database."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SqlDatabase
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sqldatabase) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SqlDatabase - Name of the SMA database."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SiteName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sitename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SiteName - Name of the SMA web site."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         WebServicePort
  # Type:         uint16
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_webserviceport) do
    def mof_type; 'uint16' end
    def mof_is_embedded?; false end
    desc "WebServicePort - Port of the SMA web site."
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         InstallFolder
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_installfolder) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "InstallFolder - Installation folder for SMA."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         UseSSL
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_usessl) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "UseSSL - Use SSL?"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SpecifyCertificate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_specifycertificate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SpecifyCertificate - Specify an existing certificate for the SMA web site."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         CertificateName
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_certificatename) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "CertificateName - Name of the existing certificate to use."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ETWManifest
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_etwmanifest) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ETWManifest - Log to ETW."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SendCEIPReports
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_sendceipreports) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SendCEIPReports - Send Customer Experience Improvement Program."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         MSUpdate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_msupdate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "MSUpdate - Use Microsoft Update."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ProductKey
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_productkey) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ProductKey - Product key for licensed installations."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         RunbookWorkerServers
  # Type:         string[]
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_runbookworkerservers, :array_matching => :all) do
    def mof_type; 'string[]' end
    def mof_is_embedded?; false end
    desc "RunbookWorkerServers - Array of Runbook Worker servers in this deployment."
    validate do |value|
      unless value.kind_of?(Array) || value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string or an array of strings")
      end
    end
    munge do |value|
      Array(value)
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_xscsmawebserviceserversetup).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
