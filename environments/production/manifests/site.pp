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
    /[Uu]buntu/:                    {include std_ubuntu }
    /[Dd]arwin/:                    {include std_mac    }
    /[Ww]indows/:                   {include std_windows}
    default:                        {include common     }
  }
}

node aperio04, vaidc01, utility01 {
  include common
}

node /zhang\d+/ {
  include research_centos
  include gdm_login_screen
  include graylog
}

node /biobankdb/ {
    include common
    include sssd
    include graylog
    include dummy_login
}

node /cryo[-_]em[_-]linux\d+/ {
  include cryoem
  include pymol_module
}

node foreman {
  include centos_server

  # backup and replace all configurations monthly
  cron { 'cleanfb_monthly': 
    command  => '/usr/bin/yes | /usr/local/bin/cleanfb --name=vai',
    user     => 'root',
    monthday => 1,
  }
}

node gongpuvictory {
  include cryoem
  include pymol_module
  include research_centos
}

node /^lens\d+$/ {
  include research_centos
}

node /matt/ {
  include common
  include sssd
  include graylog
}


node szabo1 {
  include common
  include graylog
  include sssd
  include mount_drives
  include privileges
}

