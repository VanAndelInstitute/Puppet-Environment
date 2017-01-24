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
            services = nss, pam, ssh, autofs
            domains = VAI.ORG

            [nss]

            reconnection_retries = 3
            entry_cache_timeout = 300
            entry_cache_nowait_percentage = 75

            [pam]

            [domain/vai.org]

            id_provider = ad
            auth_provider = ad
            access_provider = ad
            chpass_provider = ad

            entry_cache_timeout=16000
            refresh_expired_interval=12000

            default_shell = /bin/bash

            fallback_homedir = /home/%u

            ldap_user_objectsid=objectSid
            ldap_group_objectsid=objectSid

            # to get user information (UID/GID) from the active directory
            #ldap_user_object_class =  top
            ldap_user_home_directory = unixHomeDirectory
            #ldap_group_object_class = top
            ldap_force_upper_case_realm = True
            ldap_group_nesting_level=10
            #ldap_group_member = member
            #ldap_schema = ad
            ldap_deref_threshold=10
            ldap_id_mapping=true
            #ldap_group_objectsid=objectSid
            #ldap_idmap_autorid_compat=true
            # allow getent to query the AD
            enumerate = true
            ldap_group_nesting_level=20
            ldap_groups_use_matching_rule_in_chain=true
            ldap_initgroups_use_matching_rule_in_chain=true
            ad_enable_gc=false
            ldap_enumeration_refresh_timeout=20
            ldap_purge_cache_timeout=0

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
