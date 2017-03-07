class pymol_module {
    
  $packages = ['freeglut-devel', 'glew-devel', 'libpng-devel', 'numpy', 'freetype-devel', 'tkinter', 'libxslt-devel', 'libxml2-devel', 'python-pmw', 'gcc-c++',]

  $packages.each |$pack| {
    package { "$pack":
      ensure => 'present',
    }
  }
}
