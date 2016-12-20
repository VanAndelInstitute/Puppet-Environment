require 'pathname'

Puppet::Type.newtype(:dsc_xinternetexplorerhomepage) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xInternetExplorerHomePage resource type.
    Automatically generated from
    'xInternetExplorerHomePage/DSCResources/xInternetExplorerHomePage/xInternetExplorerHomePage.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_startpage is a required attribute') if self[:dsc_startpage].nil?
    end

  def dscmeta_resource_friendly_name; 'xInternetExplorerHomePage' end
  def dscmeta_resource_name; 'xInternetExplorerHomePage' end
  def dscmeta_module_name; 'xInternetExplorerHomePage' end
  def dscmeta_module_version; '1.0.0' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    newvalue(:absent)  { provider.destroy }
    defaultto { :present }
  end

  # Name:         StartPage
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_startpage) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "StartPage - Specifies the URL for the home page of Internet Explorer."
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         SecondaryStartPages
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_secondarystartpages) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "SecondaryStartPages - Specifies the URL for the secondary home pages of Internet Explorer."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Ensure
  # Type:         string
  # IsMandatory:  False
  # Values:       ["Present", "Absent"]
  newparam(:dsc_ensure) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Ensure - Should the IE home page is configured or unconfigured. Valid values are Present, Absent."
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

Puppet::Type.type(:dsc_xinternetexplorerhomepage).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
