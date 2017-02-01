$mac_temp               = "/root/mac_temp"
$mac_manifest           = "modules/mac/manifests/init.pp"
$development_env        = "/etc/puppetlabs/code/environments/development/"
$production_env         = "/etc/puppetlabs/code/environments/production/"
$test_env               = "/etc/puppetlabs/code/environments/test/"
$mac_repo               = "http://munki.vai.org/munki_repo/pkgs/apps"

def add_to_manifest
  
  `mkdir #{$mac_temp}` unless Dir.exist? $mac_temp
  unless (Dir.entries($mac_temp).size == 0)
    Dir.foreach($mac_temp) do |item|
      next if item == '.' or item == '..'

      tokens = item.split("_")
      return if tokens.size < 3
      
      env = tokens[0]
      manifest = tokens[1]

      environment = ((env.include? "development") ? $development_env : ((env.include? "production") ? $production_env : $test_env))

      package = (tokens[2..-1]).join("_").split(/\.tmp/)[0]
      extension = ".dmg" if package.include? "dmg"
      extension = ".pkg" if package.include? "pkg"
      package = package.split(extension)[0]
      return if extension.empty?
      
      provider = "appdmg" if extension.include? "dmg"
      provider = "pkgdmg" if extension.include? "pkg"

      pkg_template = "package { '#{package}' : \n\t\tensure => installed,\n\t\tprovider => #{provider},\n\t\tsource => '#{$mac_repo}/#{package}/#{package}#{extension}',\n\t}\n\n\t# New Package Goes Here"
      manifest_file = "#{environment}#{$mac_manifest}"
      manifest_contents = File.read(manifest_file)
      File.write(manifest_file, manifest_contents.gsub(/# New Package Goes Here/, pkg_template)) unless (manifest_contents.include? package)

      `rm -f #{$mac_temp}/#{item}`
    end
  end
end

add_to_manifest
