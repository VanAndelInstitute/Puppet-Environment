require 'pathname'

Puppet::Type.newtype(:dsc_xdhcpserverreservation) do
  require Pathname.new(__FILE__).dirname + '../../' + 'puppet/type/base_dsc'
  require Pathname.new(__FILE__).dirname + '../../puppet_x/puppetlabs/dsc_type_helpers'


  @doc = %q{
    The DSC xDhcpServerReservation resource type.
    Automatically generated from
    'xDhcpServer/DSCResources/MSFT_xDhcpServerReservation/MSFT_xDhcpServerReservation.schema.mof'

    To learn more about PowerShell Desired State Configuration, please
    visit https://technet.microsoft.com/en-us/library/dn249912.aspx.

    For more information about built-in DSC Resources, please visit
    https://technet.microsoft.com/en-us/library/dn249921.aspx.

    For more information about xDsc Resources, please visit
    https://github.com/PowerShell/DscResources.
  }

  validate do
      fail('dsc_scopeid is a required attribute') if self[:dsc_scopeid].nil?
      fail('dsc_ipaddress is a required attribute') if self[:dsc_ipaddress].nil?
    end

  def dscmeta_resource_friendly_name; 'xDhcpServerReservation' end
  def dscmeta_resource_name; 'MSFT_xDhcpServerReservation' end
  def dscmeta_module_name; 'xDhcpServer' end
  def dscmeta_module_version; '1.2' end

  newparam(:name, :namevar => true ) do
  end

  ensurable do
    newvalue(:exists?) { provider.exists? }
    newvalue(:present) { provider.create }
    newvalue(:absent)  { provider.destroy }
    defaultto { :present }
  end

  # Name:         ScopeID
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_scopeid) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ScopeID - ScopeId for which reservations are set"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         IPAddress
  # Type:         string
  # IsMandatory:  True
  # Values:       None
  newparam(:dsc_ipaddress) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "IPAddress - IP address of the reservation for which the properties are modified"
    isrequired
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         ClientMACAddress
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_clientmacaddress) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "ClientMACAddress - Client MAC Address to set on the reservation"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         Name
  # Type:         string
  # IsMandatory:  False
  # Values:       None
  newparam(:dsc_name) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "Name - Reservation name"
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
    end
  end

  # Name:         AddressFamily
  # Type:         string
  # IsMandatory:  False
  # Values:       ["IPv4"]
  newparam(:dsc_addressfamily) do
    def mof_type; 'string' end
    def mof_is_embedded?; false end
    desc "AddressFamily - Address family type Valid values are IPv4."
    validate do |value|
      unless value.kind_of?(String)
        fail("Invalid value '#{value}'. Should be a string")
      end
      unless ['IPv4', 'ipv4'].include?(value)
        fail("Invalid value '#{value}'. Valid values are IPv4")
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
    desc "Ensure - Whether option should be set or removed Valid values are Present, Absent."
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

Puppet::Type.type(:dsc_xdhcpserverreservation).provide :powershell, :parent => Puppet::Type.type(:base_dsc).provider(:powershell) do
  confine :true => (Gem::Version.new(Facter.value(:powershell_version)) >= Gem::Version.new('5.0.10240.16384'))
  defaultfor :operatingsystem => :windows

  mk_resource_methods
end
