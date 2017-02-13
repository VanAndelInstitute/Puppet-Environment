$temp               = "/root/temp/"

$mac_manifest       = "modules/mac/manifests/init.pp"
$windows_manifest   = "modules/windows/manifests/init.pp"

env_root            = "/etc/puppetlabs/code/environments/"
$development_env    = "#{env_root}development/"
$production_env     = "#{env_root}production/"
$test_env           = "#{env_root}test/"

$puppet_repo        = "http://munki.vai.org/puppet_repo/apps"

def add_to_manifest
  
  `mkdir #{$temp}` unless Dir.exist? $temp
  unless (Dir.entries($temp).size == 0)
    Dir.foreach($temp) do |item|
      next if item == '.' or item == '..' or item.nil?
      
      tokens = item.split("_")
      return if tokens.size < 3
      
      env = tokens[0]
      manifest = tokens[1]
      
      environment = ((env.include? "development") ? $development_env : ((env.include? "production") ? $production_env : $test_env))
      manifest = ((manifest.include? "standardmac") ? $mac_manifest : $windows_manifest)

      package = (tokens[2..-1]).join("_").split(/\.tmp/)[0]
      
      extension = ".dmg" if package.include? "dmg"
      extension = ".pkg" if package.include? "pkg"
      extension = ".exe" if package.include? "exe"
      extension = ".msi" if package.include? "msi"
      
      package = package.split(extension)[0]
      
      return if extension.nil? or extension.empty?
      
      provider = "appdmg"    if extension.include? "dmg"
      provider = "pkgdmg"    if extension.include? "pkg"
      provider = "windows"   if (extension.include? "exe" or extension.include? "msi")

      pkg_template = "package { '#{package}' : \n\t\tensure => installed,\n\t\tprovider => #{provider},\n\t\tsource => '#{$puppet_repo}/#{package}/#{package}#{extension}',\n\t}\n\n\t# New Package Goes Here"

      manifest_file = "#{environment}#{manifest}"
      manifest_contents = File.read(manifest_file)
      
      File.write(manifest_file, manifest_contents.gsub(/# New Package Goes Here/, pkg_template)) unless (manifest_contents.include? package)

      `rm -f #{$temp}/#{item}`
    end
  end
end

add_to_manifest
