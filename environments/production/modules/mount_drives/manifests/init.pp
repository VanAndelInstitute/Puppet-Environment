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

    package { 'cifs-utils' :
      ensure => present,
    }

	file_line { 'old_mount' :
		path         => '/etc/fstab',
		line         => '//nasgw.hpc.vai.org/software    /primary/vari/software  cifs    guest   0 0',
        ensure => absent,
	}
	
    file_line { 'mount' :
		path         => '/etc/fstab',
		line         => '//nasgw.hpc.vai.org/software    /primary/vari/software  cifs    guest,comment=systemd.automount   0 0',
	}
}
