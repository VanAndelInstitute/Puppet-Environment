node default {}

node windev1806eval {
  include chocolatey
  package { 'git':
      ensure   => latest,
      provider => 'chocolatey',
  }
  
  package { 'office365business':
      ensure   => absent,
      provider => 'chocolatey',
  }
}
