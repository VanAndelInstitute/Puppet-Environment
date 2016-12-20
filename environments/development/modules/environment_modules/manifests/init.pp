class environment_modules {
   
    $global_bash = '/etc/bashrc'

    # install the module utility
    package { 'environment-modules' :
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
    file_line { 'relion' :
		path => $global_bash,
		line => 'export PATH=$PATH:/primary/vari/software/relion/default/bin',
    }
    file_line { 'IMOD' :
		path => $global_bash,
		line => 'source /primary/vari/software/IMOD/default/IMOD-linux.sh',
    }
    file_line { 'EMAN2' :
		path => $global_bash,
		line => 'source /primary/vari/software/eman2/default/eman2.bashrc',
    }
    file_line { 'MPI_HOME' :
		path => $global_bash,
		line => 'export MPI_HOME=/usr/local',
    }
    file_line { 'MPI_RUN' :
		path => $global_bash,
		line => 'export MPI_RUN=/usr/local/bin/mpirun',
    }
    file_line { 'LIB_PATH' :
		path => $global_bash,
		line => 'export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH',
    }
    file_line { 'Add_Cuda' :
		path => $global_bash,
		line => 'module add cuda70',
    }
    file_line { 'Relion_Alias' :
		path => $global_bash,
		line => 'alias relion2=/primary/vari/software/relion/relion2-beta/build/bin/relion',
    }
    
    # Ensure that the needed modules exist
    file { 'mpich314' :
      path => '/usr/share/Modules/modulefiles/mpich314',
      ensure => present,
      content => '#%Module -*- tcl -*-
##
## dot modulefile
##

###
#   Maintained by Puppet. Any modifications to this file will be reset
#   on the next Puppet run.
###

proc ModulesHelp { } {
  puts stderr "\tAdds mpich 3.1.4 Toolkit to your environment variables,"
}

module-whatis "adds mpich 3.1.4 to your environment variables"

set               mpichversion         3.1.4
set               root                /primary/vari/software/mpich/$mpichversion
setenv            MPI_HOME            $root
setenv            MPI_RUN            $root/bin/mpirun
prepend-path      PATH                $root/bin
prepend-path      LD_RUN_PATH         $root/lib
prepend-path      LD_LIBRARY_PATH        $root/lib
prepend-path      MANPATH             $root/share/man
',
  }

    file { 'cryoem' :
      path => '/usr/share/Modules/modulefiles/cryoem',
      ensure => present,
      content => '#%Module -*- tcl -*-
##
## modulefile
##

###
#   Maintained by Puppet. Any modifications to this file will be reset
#   on the next Puppet run.
###

proc ModulesHelp { } {

  puts stderr "\tadds selected cryoem tools to your path\n"
}

module-whatis "some common cryoem tools"

set              version           1.0
set              root              /primary/vari/software
set-alias       relion2         /primary/vari/software/relion/relion2-beta/build/bin/relion
prepend-path      PATH              $root/relion/default/bin
system  /primary/vari/software/IMOD/default/add_IMOD_to_bashrc.pl
system  /primary/vari/software/eman2/default/add_eman2_to_bashrc.pl
',
  }

    file { 'cuda70' :
      path => '/usr/share/Modules/modulefiles/cuda70',
      ensure => present,
      content => '##
## dot modulefile
##

###
#   Maintained by Puppet. Any modifications to this file will be reset
#   on the next Puppet run.
###

proc ModulesHelp { } { 
  puts stderr "\tAdds NVIDIA CUDA 7.0 Toolkit to your environment variables,"
}

module-whatis "adds NVIDIA CUDA 7.0 Toolkit to your environment variables"

set               cudaversion         7.0.28
set               root                /cm/shared/apps/cuda70/toolkit/$cudaversion
setenv            CUDA_INSTALL_PATH   $root
setenv            CUDA_PATH           $root
setenv            CUDA_ROOT           /cm/local/apps/cuda/libs/current
setenv            CUDA_SDK            /cm/shared/apps/cuda70/sdk/$cudaversion
prepend-path      PATH                $root/bin
prepend-path      PATH                /cm/shared/apps/cuda70/sdk/$cudaversion/bin/x86_64/linux/release
prepend-path      LD_RUN_PATH         $root/lib
prepend-path      LIBRARY_PATH        $root/lib64
prepend-path      LD_LIBRARY_PATH     $root/lib64
prepend-path      CUDA_INC_PATH       $root
prepend-path      MANPATH                   /cm/local/apps/cuda/libs/current/share/man

# CUDA LIBARIES
prepend-path      INCLUDEPATH         $root/include
prepend-path      PATH                /cm/local/apps/cuda/libs/current/bin
prepend-path      LIBRARY_PATH        /cm/local/apps/cuda/libs/current/lib64
prepend-path      LD_RUN_PATH         /cm/local/apps/cuda/libs/current/lib64
prepend-path      LD_LIBRARY_PATH     /cm/local/apps/cuda/libs/current/lib64

# PYNVML
prepend-path      PYTHONPATH          /cm/local/apps/cuda/libs/current/pynvml

# CUDA SDK for CUDPP CUTIL
prepend-path      INCLUDEPATH         /cm/shared/apps/cuda70/sdk/$cudaversion/common/inc

# OpenCL
prepend-path      INCLUDEPATH         /cm/shared/apps/cuda70/toolkit/$cudaversion/include/CL
prepend-path      CPATH               /cm/shared/apps/cuda70/toolkit/$cudaversion/include

# OpenCL  SDK for CLUTIL
prepend-path      CPATH               /cm/shared/apps/cuda70/sdk/$cudaversion/common/inc

# CUPTI
prepend-path      INCLUDEPATH         $root/extras/CUPTI/include
prepend-path      LD_LIBRARY_PATH     $root/extras/CUPTI/lib64

# Debugger
prepend-path      INCLUDEPATH         $root/extras/Debugger/include

# Disable CUDA cache

',
  }
}
