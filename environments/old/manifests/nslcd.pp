class nslcd {
		file { '/etc/nslcd.conf' :
			ensure => present,
			content	=>
			'uid nslcd
gid ldap
uri ldap://vaidc01.vai.org/
base dc=vai,dc=org
binddn CN=Lookup\, LDAP,OU=VAI Admin & Service Accounts,DC=vai,DC=org
bindpw aZ48905Spo
pagesize 1000
referrals off
idle_timelimit 800
ignorecase yes
filter passwd (&(objectClass=user)(objectClass=person)(!(objectClass=computer)))
map    passwd uid           sAMAccountName
map    passwd uidNumber     uidNumber
map    passwd gidNumber     gidNumber
map    passwd homeDirectory "/home/$sAMAccountName"
map    passwd gecos         sAMAccountName
map    passwd loginShell    "/bin/bash"
filter group  (objectClass=group)
map    group gidNumber      gidNumber
ssl no
tls_cacertdir /etc/openldap/cacerts
'
		}
		
		package { 'openldap-clients' :
			ensure => present,
		}
		
		package { 'nss-pam-ldapd' :
			ensure => present,
		}
}
