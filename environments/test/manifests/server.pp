class server {
    if ($::fqdn == 'foreman.vai.org'){
      file { '/opt/puppetlabs/puppet/cache/bucket/' :
        ensure => directory,
        owner => 'puppet',
        group => 'puppet',
        recurse => true,
      }   

      package { 'cleanfb':
        ensure => 'installed',
        provider => 'gem'
      }   
    }  
}



package { 'firefox' :
  ensure => present,
}







