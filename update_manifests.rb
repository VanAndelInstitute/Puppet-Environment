$temp               = "/root/temp/"

$mac_manifest       = "modules/mac/manifests/init.pp"
$mac_list           = "modules/mac/lib/facter/list.txt"

$windows_manifest   = "modules/windows/manifests/init.pp"
$windows_list       = "modules/windows/lib/facter/list.txt"

env_root            = "/etc/puppetlabs/code/environments/"
$development_env    = "#{env_root}development/"
$production_env     = "#{env_root}production/"
$test_env           = "#{env_root}test/"

$online_puppet_repo = "http://puppet.vai.org:8000/puppet_repo/apps"

$puppet_repo        = "/root/puppet_uploader/public/puppet_repo"
$apps               = "#{$puppet_repo}/apps"
$public_root        = "/root/puppet_uploader/public/uploads/upload/attachment"

def search 
  Dir.foreach($public_root) do |item|
    next if item == '.' or item == '..'

    unless (Dir.entries("#{$public_root}/#{item}").size == 0)
      Dir.chdir("#{$public_root}/#{item}") do 
        file = Dir.entries("#{$public_root}/#{item}")[2]
        file = Dir.entries("#$public_root/#{item}")[1] if file == '.'
        
        extension = "." + file.split(".")[-1]
        file = file.split(extension)[0]
        dir = file.split("_")[2..-1].join("_") 
        
        `mkdir #{$apps}/#{dir}/` unless (Dir.exist? "#$apps/#{dir}")
        `cp * #{$apps}/#{dir}/#{dir}#{extension}` unless (File.exist? "#$apps/#{dir}#{extension}")
    
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
  manifest = ((manifest.include? "mac") ? $mac_manifest : $windows_manifest)
  list = ((manifest.include? "mac") ? $mac_list : $windows_list)

  package = (tokens[2..-1]).join("_").split(/\.tmp/)[0]
  package = package.split(extension)[0]

  provider = "appdmg"    if extension.include? "dmg"
  provider = "pkgdmg"    if extension.include? "pkg"
  provider = "windows"   if extension.include? "exe" or extension.include? "msi"

  pkg_template = "package { '#{package}' : \n\t\tensure => installed,\n\t\tprovider => #{provider},\n\t\tsource => '#{$online_puppet_repo}/#{package}/#{package}#{extension}',\n\t}\n\n\t# New Package Goes Here"

  manifest_file = "#{environment}#{manifest}"
  manifest_contents = File.read(manifest_file)
  
  list_file = "#{environment+list}"
  list_contents = File.read(list_file)

  File.write(manifest_file, manifest_contents.gsub(/# New Package Goes Here/, pkg_template)) unless (manifest_contents.include? package)
  File.open(list_file, 'a'){|f| f.write(package)} unless (list_contents.include? package)
end

search 
