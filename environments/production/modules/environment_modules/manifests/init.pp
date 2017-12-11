class environment_modules {
   
  $global_bash = '/etc/bashrc'

  $packages = [ 'epel-release', 'environment-modules', 'libgfortran', 'libgnomecanvas', 'libpng12', 'bzr', 'make', 'cmake', 'wget', 'gcc-gfortran', 'm4', 'patch', 'qt-devel', 'qtwebkit-devel', 'python-devel', 'java-devel', 'fontconfig-devel', 'libXt-devel', 
    'libXrender-devel', 'libXinerama-devel', 'libXaw-devel', 'swig', 'xz', 'intltool', 'mesa-libGLU-devel', 'libXmu-devel', 'gtk+', 'gtk+-devel', 'webkitgtk', 'compat-libtiff3']
  
  $packages.each |$pack| {
    package { "$pack":
      ensure => present,
    }
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
    
  file { 'add_relion':
    path    => '/etc/profile.d/z_add_relion.sh',
    ensure  => present,
    mode    => '0755',
    content => 'export PATH=$PATH:/primary/vari/software/relion/default/bin
    
    ',
  }

  if (!($::fqdn =~ "lens")){
    file { 'add_mpich':
      path    => '/etc/profile.d/z_add_mpich.sh',
      ensure  => present,
      mode    => '0755',
      content => "module add mpich314
       
      ",
    }
    
    file { 'x_module_path':
      path    => '/etc/profile.d/x_module_path.sh',
      ensure  => 'present',
      mode    => '0755',
      content => 'export MODULEPATH=/primary/vari/software/modules/linuxworkstation:$MODULEPATH
      ',
    }

    file { 'add_cryoem':
      path    => '/etc/profile.d/z_add_cryoem.sh',
      ensure  => present,
      mode    => '0755',
      content => "module add cryoem
      
      ",
    }
    
    if !($::fqdn =~ /[Cc]ryo/){
      file { 'add_cuda':
        path    => '/etc/profile.d/z_add_cuda.sh',
        ensure  => present,
        mode    => '0755',
        content => "module add cuda70
      
        ",
      }
    }
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
  
  if ($::fqdn =~ /[Cc]ryo/ or $::fqdn =~ /[Gg]ongpu/ or $::fqdn =~ /[Mm]att/){
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

    file { 'start_cryosparc':
      path    => '/root/start_cryosparc.sh',
      ensure  => present,
      mode    => '0777',
      content => 'cryosparc start',
    }

    file { 'cryosparc':
      path    => '/etc/profile.d/x_add_cryosparc.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export PATH="/opt/cryosparc/bin":$PATH',
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
    
    file { 'chimera':
      path    => '/etc/profile.d/chimera.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export PATH=/primary/vari/software/chimera/default/bin:$PATH
    
      ',
    }
    
    file { 'add_frealign':
      path    => '/etc/profile.d/z_add_frealign.sh',
      ensure  => present,
      mode    => '0755',
      content => 'export PATH=${PATH}:/opt/frealign_v9.11/bin
      
      ',
    }
  }
}
