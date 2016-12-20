require 'erb'
require 'dsc_utils'
test_name 'MODULES-2229 - C68757 - Attempt to Apply DSC User Resource with Invalid Data Type for "PasswordNeverExpires" Specified'

confine(:to, :platform => 'windows')

# Init
local_files_root_path = ENV['MANIFESTS'] || 'tests/manifests'

# ERB Manifest
dsc_type = 'user'
dsc_module = 'PSDesiredStateConfiguration'
dsc_props = {
  :dsc_ensure               => 'Present',
  :dsc_username             => 'goatkong',
  :dsc_passwordneverexpires => 2
}

dsc_manifest_template_path = File.join(local_files_root_path, 'basic_dsc_resources', 'dsc_single_resource.pp.erb')
dsc_manifest = ERB.new(File.read(dsc_manifest_template_path), 0, '>').result(binding)

# Verify
error_msg = /Error:.*invalid value/m

# Tests
agents.each do |agent|
  step 'Attempt to Apply Manifest'
  on(agent, puppet('apply'), :stdin => dsc_manifest, :acceptable_exit_codes => 1) do |result|
    assert_match(error_msg, result.stderr, 'Expected error was not detected!')
  end
end
