node default {}

node windev1806eval {
  include chocolatey
  include common
  package { 'git':
      ensure   => latest,
      provider => 'chocolatey',
  }
  
  package { 'office365business':
      ensure   => latest,
      provider => 'chocolatey',
  }

  package { 'notepadplusplus':
    ensure   => latest,
    provider => 'chocolatey',
  }

  package { 'spotify':
    ensure   => absent,
    provider => 'chocolatey',
  }

  package { 'slack':
    ensure   => latest,
    provider => 'chocolatey',
  }

}
