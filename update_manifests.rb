$temp               = "/root/temp/"

$mac_manifest       = "modules/mac/manifests/init.pp"
$windows_manifest   = "modules/windows/manifests/init.pp"

env_root            = "/etc/puppetlabs/code/environments/"
$development_env    = "#{env_root}development/"
$production_env     = "#{env_root}production/"
$test_env           = "#{env_root}test/"

$online_puppet_repo = "https://puppet.vai.org:8000/puppet_repo/apps"

$puppet_repo    = "/root/puppet_uploader/public/puppet_repo"
$apps           = "#{$puppet_repo}/apps"
$public_root    = "/root/puppet_uploader/public/uploads/upload/attachment"

def search 
  Dir.foreach($public_root) do |item|
    next if item == '.' or item == '..'
    unless (Dir.entries("#{$public_root}/#{item}").size == 0)
      Dir.chdir("#{$public_root}/#{item}") do
        file = Dir.entries("#{$public_root}/#{item}")[1]
        
        extension = "." + file.split(".")[-1]
        file = file.split(extension)[0]
        dir = file.split("_")[2..-1].join("_") 
        
        `mkdir #{$apps}/#{file}/` unless (Dir.exist? file)
        `cp * #{$apps}/#{file}/#{file}#{extension}` unless (File.exist? "#{file}#{extension}")
    
        add_to_manifest(file, extension)
      end 
    end 
    `rm -rf #{$public_root}/#{item}`
  end 
end

def add_to_manifest(file, extension)
  
      tokens = file.split("_")
      
      env = tokens[0]
      manifest = tokens[1]
      
      environment = ((env.include? "development") ? $development_env : ((env.include? "production") ? $production_env : $test_env))
      manifest = ((manifest.include? "standardmac") ? $mac_manifest : $windows_manifest)

      package = (tokens[2..-1]).join("_").split(/\.tmp/)[0]
      package = package.split(extension)[0]
      
      provider = "appdmg"    if extension.include? "dmg"
      provider = "pkgdmg"    if extension.include? "pkg"
      provider = "windows"   if extension.include? "exe" or extension.include? "msi"

      pkg_template = "package { '#{package}' : \n\t\tensure => installed,\n\t\tprovider => #{provider},\n\t\tsource => '#{$online_puppet_repo}/#{package}/#{package}#{extension}',\n\t}\n\n\t# New Package Goes Here"

      manifest_file = "#{environment}#{manifest}"
      manifest_contents = File.read(manifest_file)
      
      File.write(manifest_file, manifest_contents.gsub(/# New Package Goes Here/, pkg_template)) unless (manifest_contents.include? package)
end

search 
