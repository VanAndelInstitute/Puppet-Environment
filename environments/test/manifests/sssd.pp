include krb5
include samba

class sssd {
		file { '/etc/sssd/sssd.conf' :
			ensure => present,
			mode 	=> '0600',
			content	=>
			'## This configuration file is managed by Puppet.
## Any changes made to it will be reset on the next Puppet run.

[sssd]
config_file_version = 2
reconnection_retries = 3
sbus_timeout = 30
services = nss, pam, pac
domains = LOCAL, VAI.ORG

[pam]
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5

[nss]
filter_groups = root
filter_users = root
reconnection_retries = 3
entry_cache_timeout = 300
entry_cache_nowait_percentage = 75
default_shell = /bin/bash

[pac]

[domain/LOCAL]
description = LOCAL Users domain
id_provider = local
enumerate = true

[domain/VAI.ORG]
id_provider = ad
auth_provider = ad
chpass_provider =ad
access_provider = ad

cache_credentials = true

ldap_id_mapping = false
ldap_referrals = false

default_shell = /bin/bash
override_homedir = /home/%u
'
		}

		package { 'sssd' :
			ensure => present,
		}
		
		exec { 'authconfig-sssd' :
			command 	=> '/usr/bin/net ads join -U admMattH%Puppetisc00l; /usr/sbin/authconfig --enablesssd --enablesssdauth --enablemkhomedir --updateall', 
			refreshonly => true,
		}
		
		service { 'sssd' :
			ensure 		=> running,
			enable 		=> true,
			subscribe => Exec['authconfig-sssd'],
		}

		service { 'crond' :
			subscribe	=>	Service['sssd'],
		}
}
