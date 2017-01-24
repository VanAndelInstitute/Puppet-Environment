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




# Research machines include /primary/vari/software mounts 
# as well as environment modules. Standard machines do not.

node default {
  if ($::operatingsystem == 'centos'){
    include std_centos
    #  class { 'sudo': }
    #  class { 'privileges': }
  }
}
node matt {
  include research_centos
  include pymol_module
}
node vais-macbook-pro-3 {
  include std_mac
}
node /^lens\d+$/ {
  include research_centos
}
node foreman {
  include std_centos
  include server
}
node /bio\d+/ {
  include research_centos
}
node /cryo[-_]em[_-]linux\d+/ {
  include cryoem
  include pymol_module
}
node gongpuvictory {
  include cryoem
  include pymol_module
}
node one {
  include std_centos
}
