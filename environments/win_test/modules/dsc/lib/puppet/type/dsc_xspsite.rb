require 'pathname'

Puppet::Type.newtype(:dsc_xspsite) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xSPSite resource type.
    Automatically generated from
    'xSharePoint/Modules/xSharePoint/DSCResources/MSFT_xSPSite/MSFT_xSPSite.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_url is a required attribute') if self[:dsc_url].nil?
    end

  def dscmeta_resource_friendly_name; 'xSPSite' end
  def dscmeta_resource_name; 'MSFT_xSPSite' end
  def dscmeta_module_name; 'xSharePoint' end
  def dscmeta_module_version; '0.7.0.0' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    defaultto { :present }
  end

  # Name:         Url
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_url) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Url"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         OwnerAlias
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_owneralias) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "OwnerAlias"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         CompatibilityLevel
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_compatibilitylevel) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "CompatibilityLevel"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         ContentDatabase
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_contentdatabase) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ContentDatabase"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Description
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_description) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Description"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         HostHeaderWebApplication
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_hostheaderwebapplication) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "HostHeaderWebApplication"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Language
  # Type:         uint32
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_language) do
    def mof_type; 'uint32' end
    def mof_is_embedded?; false end
    desc "Language"
    validate do |value|
      unless (value.kind_of?(Numeric) && value >= 0) || (value.to_i.to_s == value && value.to_i >= 0)
          fail("Invalid value #{value}. Should be a unsigned Integer")
      end
    end
    munge do |value|
      PuppetX::Dsc::TypeHelpers.munge_integer(value)
    end
  end

  # Name:         Name
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_name) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Name"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         OwnerEmail
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_owneremail) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "OwnerEmail"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         QuotaTemplate
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_quotatemplate) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "QuotaTemplate"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SecondaryEmail
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_secondaryemail) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SecondaryEmail"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SecondaryOwnerAlias
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_secondaryowneralias) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SecondaryOwnerAlias"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Template
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_template) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Template"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         InstallAccount
  # Type:         MSFT_Credential
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_installaccount) do
    def mof_type; 'MSFT_Credential' end
    def mof_is_embedded?; true end
    desc "InstallAccount"
    validate do |value|
      unless value.kind_of?(Hash)
        fail("Invalid value '#{value}'. Should be a hash")
      end
      PuppetX::Dsc::TypeHelpers.validate_MSFT_Credential("InstallAccount", value)
    end
  end


  def builddepends
    pending_relations = super()
    PuppetX::Dsc::TypeHelpers.ensure_reboot_relationship(self, pending_relations)
  end
end

Puppet::Type.type(:dsc_xspsite).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
