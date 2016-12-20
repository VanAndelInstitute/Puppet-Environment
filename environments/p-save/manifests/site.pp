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
  
  if ($::operatingsystem != 'windows'){
    $doc_root = '/root/'
    file { '/bin/puppet' :
      ensure             => present,
      source             => '/opt/puppetlabs/puppet/bin/puppet',
      source_permissions => use,
    }
    file { '/bin/facter' :
      ensure             => present,
      source             => '/opt/puppetlabs/puppet/bin/facter',
      source_permissions => use,
    }
		if ($::fqdn == 'foreman.vai.org'){
			file { '/opt/puppetlabs/puppet/cache/bucket/' :
				ensure => directory,
				owner => 'puppet',
				group => 'puppet',
				recurse => true,
			}

			package { 'cleanfb':
				ensure => 'installed',
				provider => 'gem'
			}

  	}
		
		package { 'ruby':
			ensure => present,
		}
			
		package { 'ruby-devel':
			ensure => present,
		}

		package { 'gcc':
			ensure => present,
		}

		package { 'puppet':
			ensure => 'installed',
			provider => 'gem'
		}
		
#		package { 'ruby-ldap':
#			ensure => present,
#			provider => 'gem'
#		}
		
		package { 'make':
			ensure => present,
		}
		
		#package { 'activemq':
		#	ensure => present,
		#}

		#package { 'activemq-info-provider':
		#	ensure => present,
		#}

		package { 'ruby-augeas':
			ensure => present,
		}

		#package { 'ruby-rgen':
		#	ensure => present,
		#}

		package { 'ruby-shadow':
			ensure => present,
		}

		package { 'facter':
			ensure => present,
		}

		package { 'hiera':
			ensure => present,
		}

		package { 'mcollective':
			ensure => present,
		}

		package { 'mcollective-client':
			ensure => present,
		}

		package { 'mcollective-common':
			ensure => present,
		}

		package { 'epel-release':
			ensure => present,
		}			
		
		#package { 'puppetlabs-release':
		#	ensure => present,
		#}

		package { 'ffi':
			ensure => 'installed',
			provider => 'gem'
		}
					
		package { 'net-ping':
			ensure => 'installed',
			provider => 'gem'
		}

		package { 'puppet-lint':
			ensure => 'installed',
			provider => 'gem'
		}

		package { 'rake-compiler':
			ensure => 'installed',
			provider => 'gem'
		}
		
		package { 'stomp':
			ensure => 'installed',
			provider => 'gem'
		}
		
		package { 'deep_merge':
			ensure => 'installed',
			provider => 'gem'
		}

		#if ($::fqdn != 'foreman.vai.org'){
			#exec { 'yum Group Install':
			#	unless => '/usr/bin/yum grouplist "GNOME Desktop" | /bin/grep "^Installed Groups"',
				#command => '/usr/bin/yum -y groupinstall "GNOME Desktop"',
		#	}
		#}
	}
}

