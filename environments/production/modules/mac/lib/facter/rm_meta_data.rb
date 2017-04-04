def compare_app_with puppet_app, apps, count=0
    p = puppet_app.split("_installed_")[1]
    apps.each { |app| count += 1 if !app.include? p and !p.include? app }

    # allow Puppet to reinstall the App
    File.delete("#$puppet_db_dir/#{puppet_app}") if count == apps.length
end

def check_file 
  list_file = "/opt/puppetlabs/puppet/cache/lib/facter/list.txt"
end

def search 
  return unless (Facter.value(:operatingsystem).downcase == "darwin")

  $puppet_db_dir  = "/private/var/db"
  $apps_dir       = "/Applications/"
  puppet_db, apps = [], []
 
  # retrieve the list of items installed by puppet 
  Dir.foreach($puppet_db_dir) { |item| (puppet_db << item.downcase) if item =~ /\.puppet/ }
  # retrieve all the items in the Applications folder
  Dir.foreach($apps_dir) { |item| (apps << item.split(".app")[0].downcase) unless (item == '.' or item == '..') }
  
  # check to see if any items installed by puppet are not in Applications
  puppet_db.each { |puppet_app| compare_app_with puppet_app, apps }
end

search # Search for any applications that should be installed but are not and force Puppet to reinstall them.
