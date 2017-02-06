## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

# Research machines include /primary/vari/software mounts 
# as well as environment modules. Standard machines do not.

# The cryoEM module includes the research_centos module.

node default {
  case $facts['os']['name'] {
    /[Rr]ed[Hh]at|[Cc]ent[OS|os]/:  {include std_centos }
    /[Dd]arwin/:                    {include std_mac    }
    default:                        {include common     }
  }
}

node /^test\d+$/ {
  include cryoem
}

node matt {
  include research_centos
  include pymol_module
}

node /^lens\d+$/ {
  include research_centos
}

node foreman {
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

node munki {
  include std_centos
  include mount_drives
}
