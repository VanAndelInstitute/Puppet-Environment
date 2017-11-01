# encoding: utf-8
require 'facter'
require 'digest'

class Configuration
  
  #join_info = Dir.chdir(File.dirname(__FILE__)){File.read("ad_join_info.json")}
  @@SERVER = "foreman.vai.org"#(JSON.parse(join_info))["server"]

  @@WINDOWS_PATH = "C:/ProgramData/PuppetLabs/facter/facts.d/"
  @@LINUX_PATH = "/root/" #/opt/puppetlabs/facter/facts.d/"
  
  def initialize
    @os             = facter_call(:operatingsystem).downcase
    @fqdn           = facter_call(:fqdn).downcase
    
    @filepath       = (@os.include? "windows") ? @@WINDOWS_PATH : @@LINUX_PATH
    prefix          = "#{@filepath+@fqdn}"
    @config_file    = prefix + "_configuration.json"
    @drift_file     = prefix + "_drift.json"  

    @configuration  = capture_configuration
  end

  def run
    restore_configuration if missing_configuration
    capture_configuration
    compare_configuration
    save
  end

  private

  def capture_configuration
   puppet_call(:notice, "Capturing current configuration...")

    json_array = []
    json_array.push({"name" => "ip address", "version" => facter_call(:ipaddress)})
    json_array.push({"name" => "mac address", "version" => facter_call(:macaddress)})

    packages = 
      if @os == 'darwin'
        out = `system_profiler SPApplicationsDataType`
        out.scan(/(.)+:(\s)+Version:(.)+/) {packages << $~}
      else
        out = (`puppet resource package`).split(/\n/)
        out.each_slice(3).map {|slice| slice.join("\n")}
      end
    
    packages.each {|pack| json_array.push(extract_info_from pack)}

    return JSON.generate({:packages => json_array})
  end

  def compare_configuration
    
    sum = Digest::MD5.file @config_file
    response = filebucket_request(:get, sum: sum)
    
    File.delete(@config_file, @drift_file) if(response.nil? || response.empty?)

    saved_configuration = facter_call(:packages)
    
    if(@configuration == saved_configuration) 
      puppet_call(:notice, "No drift detected on #{@fqdn}.")
    else
      current_array = @configuration.to_s.to_a
      saved_array = saved_configuration.to_a
      difference = (current_array - saved_array) + (saved_array - current_array)

      difference.each do |d|
        msg = d["name"] + " " + d["version"]

        if !(current_array.to_s.include? saved_array.to_s)
          msg.concat(" not found on #{@fqdn}.")
        elsif !(saved_array.to_s.include? d)
          msg.concat(" installed on #{@fqdn} after configuration.")
        else
          current_array.each do
            if x["name"] == d["name"] && x["version"] != d["version"]
              msg.concat(" replaced by " + x["name"] + " " + x["version"] + ".") 
            end
          end
        end

        puppet_call(notice, "#{msg}") unless msg.to_s.empty?
        @current_drift += msg.to_s unless @current_drift.include? msg.to_s
      end

      prev_drift = facter_call(:drift)
      prev_drift = @current_drift if prev_drift.strip.empty?

      drift?(prev_drift, @current_drift) ? puppet_call(:warn) : puppet_call(:err)

      msg = "Wow! Drift detected on #{@fqdn}"
    end
  end
  
  def missing_configuration
    File.exist? @config_file
  end

  def drift?(d1, d2)
    d1.gsub(/\s/,"") == d2.gsub(/\s/, "")
  end

  def save
    File.write(@config_file, @configuration)

    filebucket_request(:local_backup, file: @config_file)
    filebucket_request(:remote_backup, file: @config_file)
  end

  def restore_configuration
    list = filebucket_request(:list)
    restored = false

    unless list.nil? || list.empty?
      cached_files = list.split("\n")

      cached_files.reverse_each do |line|
        next if !(line.include? file) || restored

        sum = line.split(" ")[0]
        response = filebucket_request(:get, sum: sum)

        unless response.nil? || response.empty? || restored

          restored = true
          filebucket_request(:restore, file: @config_file, sum: sum)
          puppet_call(notice, "Restored #{@config_file} from #{@@SERVER} (#{sum})")
        end
      end 
    end
  end

  def filebucket_request(type, file: "", sum: "")
    cmd = (@os.include? "windows") ? "puppet" : "/opt/puppetlabs/bin/puppet"
    case type
    when /get/
      `#{cmd} filebucket get #{sum} --server #{@@SERVER}`
    when /restore/
      `#{cmd} filebucket restore #{file} #{sum} --server #{@@SERVER}`
    when /local_backup/
      `#{cmd} filebucket backup #{file} -l`
    when /remote_backup/
      `#{cmd} filebucket backup #{file} --server #{server}`
    when /list/ 
      `#{cmd} filebucket -l list`
    end
  end

  def puppet_call(type, val)
    case type
    when /warn/
      Puppet.warning val
    when /err/
      Puppet.err val
    when /notice/
      Puppet.notice val
    end
  end

  def facter_call val
    (Facter.value(val.to_sym))
  end

  def extract_info_from pack
    return if pack.nil?

    name = 
      if @os == 'darwin'
       (pack.to_s.match(/.*:/).to_s).gsub(/:/, "").strip 
      else
        ((pack.match(/\'.*\':/)).to_s).gsub(/\'|:/, "")
      end

    version = 
      if @os == 'darwin'
        (pack.to_s.match(/Version:.*/).to_s).gsub(/Version:/, "").strip 
      else
        ((pack.match(/\'.*\',/)).to_s).gsub(/\'|,/, "")
      end
    
    return {"name" => name, "version" => version}
  end
end

Configuration.new.run
