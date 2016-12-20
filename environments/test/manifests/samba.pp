class samba {
		file { '/etc/samba/smb.conf' :
			ensure => present,
			content	=>
			'## This configuration file is managed by Puppet.
## Any changes made to it will be reset on the next Puppet run.

[global] 
workgroup = VAI
client signing = yes 
client use spnego = yes
kerberos method = secrets and keytab
realm = VAI.ORG
security = ads 
log file = /var/log/samba/log.%m 
max log size = 50
'
		}
}
