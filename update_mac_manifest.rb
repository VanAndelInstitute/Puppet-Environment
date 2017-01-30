$mac_temp       = "/root/mac_temp"
$mac_manifest   = "/etc/puppetlabs/code/environments/development/modules/mac/manifests/init.pp"
$mac_repo       = "http://munki.vai.org/munki_repo/pkgs/apps"

def add_to_manifest
  unless (Dir.entries($mac_temp).size == 0)
    Dir.foreach($mac_temp) do |item|
      next if item == '.' or item == '..'
      
      package = item.split(/\.tmp/)[0]
      extension = ".dmg" if package.include? "dmg"
      extension = ".pkg" if package.include? "pkg"
      package = package.split(extension)[0]
      return if extension.empty?
      
      provider = "appdmg" if extension.include? "dmg"
      provider = "pkgdmg" if extension.include? "pkg"

      pkg_template = "package { '#{package}' : \n\t\tensure => installed,\n\t\tprovider => #{provider},\n\t\tsource => '#{$mac_repo}/#{package}/#{package}#{extension}',\n\t}\n\n\t# New Package Goes Here"
      manifest_contents = File.read($mac_manifest)
      File.write($mac_manifest, manifest_contents.gsub(/# New Package Goes Here/, pkg_template)) unless (manifest_contents.include? package)

      `rm -f #{$mac_temp}/#{item}`
    end
  end
end

add_to_manifest
