## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {
  include common
  include mount_drives
  include sssd
  include sshd
}

node testmatt {
	include common
	include mount_drives
	include sssd
}
node localhost.localdomain {
	include common
	include mount_drives
	include sssd
}
node puppetSSSDtest {
	include common
	include mount_drives
	include sssd
}
node gongpuvictory {
	include common
	include mount_drives
	include sssd
	include sshd
}
node foreman {
	include common
	include mount_drives
	include sssd
	include sshd
}
node lens1 {
	include common
	include mount_drives
	include sssd
	include sshd
}
node lens2 {
	include common
	include mount_drives
	include sssd
	include sshd
}
node lens3 {
	include common
	include mount_drives
	include sssd
	include sshd
}
