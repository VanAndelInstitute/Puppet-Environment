# Class: local_security_policy
#
# This module manages local_group_policy
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class local_group_policy {
	local_group_policy { 'Specify intranet Microsoft update service location':
	   ensure => 'present',
	   policy_settings => {
	      'Set the intranet statistics server:' => 'https://demo.host.com',
	      'Set the intranet update service for detecting updates:' => 'https://demo.host.com',
	   }
	}
}
