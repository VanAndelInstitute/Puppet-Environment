class mount_drives {

	file { '/primary/' :
		ensure => directory,
	}
	file { '/primary/vari/' :
		ensure => directory,
	}
	file { '/primary/vari/software/' :
		ensure => directory,
	}

	file_line { 'mount' :
		path => '/etc/fstab',
		line => '//nasgw.hpc.vai.org/software    /primary/vari/software  cifs    guest   0 0'
	}
}
