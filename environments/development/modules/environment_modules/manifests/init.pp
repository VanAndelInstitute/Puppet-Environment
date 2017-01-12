class environment_modules {
   
    $global_bash = '/etc/bashrc'

    # install the module utility
    package { 'environment-modules' :
      ensure => present,
    }
    
    package { 'libgfortran' :
      ensure => present,
    }
    
    package { 'libgnomecanvas' :
      ensure => present,
    }
  
    # create the /cm/share/apps location
    file { '/cm' :
      ensure => 'directory',
    }
    file { '/cm/shared' :
      ensure => 'directory',
    }

    # link the apps to the primary/vari/software
    file { '/cm/shared/apps' :
      ensure => 'link',
      target => '/primary/vari/software',
    } 

    # Set up the path
    file_line { 'Comment' :
		path => $global_bash,
		line => '## Managed by Puppet.',
    }
      
    file { 'x_module_path':
      path    => '/etc/profile.d/x_module_path.sh',
      ensure  => 'present',
      mode    => '0755',
      content => 'export MODULEPATH=/primary/vari/software/modules/linuxworkstation:$MODULEPATH
      ',
    }

    file { 'add_relion':
      path    => '/etc/profile.d/z_add_relion.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export PATH=$PATH:/primary/vari/software/relion/default/bin
      
      ',
    }

    file { 'add_mpich':
      path    => '/etc/profile.d/z_add_mpich.sh',
      ensure  => present,
      mode    => '0755',
      content => "module add mpich314
      
      ",
    }

    file { 'add_cryoem':
      path    => '/etc/profile.d/z_add_cryoem.sh',
      ensure  => present,
      mode    => '0755',
      content => "module add cryoem
      
      ",
    }
    
    file { 'add_MPIHOME':
      path    => '/etc/profile.d/z_add_mpihome.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export MPI_HOME=/usr/local
      
      ',
    }
    file { 'add_MPIRUN':
      path    => '/etc/profile.d/z_add_mpirun.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export MPI_RUN=/usr/local/bin/mpirun
      
      ',
    }
    
    file { 'add_LIB':
      path    => '/etc/profile.d/z_add_lib.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH,
      
      '
    }
    
    file { 'add_cuda':
      path    => '/etc/profile.d/z_add_cuda.sh',
      ensure  => present,
      mode    => '0755',
      content => "module add cuda70
      
      ",
    }

    file { 'add_relionalias':
      path    => '/etc/profile.d/z_add_relionalias.sh',
      ensure  => present,
      mode    => '0755',
      content => "alias relion2=/primary/vari/software/relion/relion2-beta/build/bin/relion
      
      ",
    }
    
    file { 'mod_fix':
      path    => '/etc/profile.d/mod_fix.sh',
      ensure  => present,
      mode    => '0755',
      content => "source /etc/profile.d/modules.sh
      
      ",
    }
    
    if ($::fqdn =~ /[Cc]ryo/ or $::fqdn =~ /[Gg]ongpu/){
      file { 'spiderweb':
        path    => '/etc/profile.d/spider.sh',
        ensure  => present,
        mode    => '0755',
        content => 'export SPIDER_DIR="/opt/spider"
        export SPBIN_DIR="$SPIDER_DIR/bin/"
        export SPMAN_DIR="$SPIDER_DIR/man/"
        export SPPROC_DIR="$SPIDER_DIR/proc/"
        export PATH="${SPIDER_DIR}/bin:${PATH}"
       ',
      }
      file { 'eman2':
        path    => '/etc/profile.d/eman2.sh',
        ensure  => present,
        mode    => '0755',
       content => "source /opt/EMAN2/eman2.bashrc
      
        ",
      }
      file { 'phenix':
        path    => '/etc/profile.d/phenix.sh',
        ensure  => present,
        mode    => '0755',
       content => "source /usr/local/phenix-1.11.1-2575/phenix_env.sh
      
        ",
      }
      file { 'coot':
        path    => '/etc/profile.d/coot.sh',
        ensure  => present,
        mode    => '0755',
       content => 'export PATH=/opt/coot-Linux-x86_64-rhel-6-gtk2-python/bin:$PATH
      
        ',
      }
    }
}
