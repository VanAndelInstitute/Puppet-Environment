require 'erb'
require 'dsc_utils'
test_name 'MODULES-2523 - C68584 - Attempt to Apply DSC Group Resource with User Collision Between "MembersToExclude" and "MembersToInclude"'

confine(:to, :platform => 'windows')

# Init
local_files_root_path = ENV['MANIFESTS'] || 'tests/manifests'

# ERB Manifest
dsc_type = 'group'
dsc_module = 'PSDesiredStateConfiguration'
dsc_props = {
  :dsc_ensure           => 'Present',
  :dsc_groupname        => 'Tension',
  :dsc_memberstoinclude => '["Administrator","Guest"]',
  :dsc_memberstoexclude => '["Administrator","Guest"]'
}

dsc_manifest_template_path = File.join(local_files_root_path, 'basic_dsc_resources', 'dsc_single_resource.pp.erb')
dsc_manifest = ERB.new(File.read(dsc_manifest_template_path), 0, '>').result(binding)

# Verify
error_msg = /Error:.*The same principal must not be included in both MembersToInclude and MembersToExclude/m

# Tests
agents.each do |agent|
  step 'Attempt to Apply Manifest'
  on(agent, puppet('apply'), :stdin => dsc_manifest, :acceptable_exit_codes => 0) do |result|
    assert_match(error_msg, result.stderr, 'Expected error was not detected!')
  end
end
