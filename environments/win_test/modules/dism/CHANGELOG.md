##2015-09-01 - Release 1.2.0
###Summary

Add source and limitaccess parameters to allow for local offline install

###Features
- All runs now will run with /Quiet
- Munge truthy and falsy values to be of type boolean
- Add source param to allow for local access source
- Add limitaccess parameter

###Bugfixes
- Remove legacy ensurable block to ensure compatibility with Puppet 4.x

##2014-11-25 - Release 1.1.0
###Summary

Add the ability to specify NoRestart (MODULES-1389)

##2014-08-06 - Release 1.0.0
###Summary

Preparing for Puppet 3.7 and x64 Ruby, refacter dism executable lookup and
refactored to only look for resource once.

##2014-07-15 - Release 0.2.1
###Summary

This release merely updates metadata.json so the module can be uninstalled and
upgraded via the puppet module command.

##2014-06-18 - Release 0.2.0
###Features
- Added 'all' parameter to indicate whether or not all dependencies should be
installed
- Add support for additional exit codes
- Add workaround for https://bugs.ruby-lang.org/issues/8083
- Add Apache 2.0 License

###Bugfixes
- Documentation typo fix
