$os = Facter.value(:operatingsystem)
def extract_info_from pack 
  return if pack.nil? #|| pack.empty?

  name = ($os == 'darwin') ? (pack.to_s.match(/.*:/).to_s).gsub(/:/, "").strip : ((pack.match(/\'.*\':/)).to_s).gsub(/\'|:/, "") 
  version = ($os == 'darwin') ? (pack.to_s.match(/Version:.*/).to_s).gsub(/Version:/, "").strip : ((pack.match(/\'.*\',/)).to_s).gsub(/\'|,/, "") 
  {"name" => name, "version" => version}
end
