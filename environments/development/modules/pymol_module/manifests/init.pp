class pymol_module {
   
    package { 'freeglut-devel' :
      ensure => present,
    }
    
    package { 'glew-devel' :
      ensure => present,
    }
    
    package { 'libpng-devel' :
      ensure => present,
    }

    package { 'numpy' :
      ensure => present,
    }

    package { 'freetype-devel' :
      ensure => present,
    }

    package { 'tkinter' :
      ensure => present,
    }

    package { 'libxslt-devel' :
      ensure => present,
    }

    package { 'libxml2-devel' :
      ensure => present,
    }

    package { 'python-pmw' :
      ensure => present,
    }

    package { 'gcc-c++' :
      ensure => present,
    }
}
