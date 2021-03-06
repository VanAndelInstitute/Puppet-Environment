# encoding: utf-8
require 'digest'
require_relative 'lib/silence_output.rb'

class Configuration
  
  join_info = Dir.chdir(File.dirname(__FILE__)){File.read("ad_join_info.json")}
  @@SERVER = (JSON.parse(join_info))["server"]

  @@WINDOWS_PATH = "C:/ProgramData/PuppetLabs/facter/facts.d/"
  @@LINUX_PATH = "/opt/puppetlabs/facter/facts.d/"

  @@WINDOWS_PUPPET = "puppet"
  @@LINUX_PUPPET = "/opt/puppetlabs/bin/puppet"
  
  def initialize
    @os             = facter_call(:operatingsystem).downcase
    @fqdn           = facter_call(:fqdn).downcase

    @filepath       = (@os.include? "windows") ? @@WINDOWS_PATH : @@LINUX_PATH
    prefix          = "#{@filepath+@fqdn}"
    @config_file    = prefix + "_configuration.json"
    @drift_file     = prefix + "_drift.json"  

    @puppet_cmd     = (@os.include? "windows") ? @@WINDOWS_PUPPET : @@LINUX_PUPPET

    @configuration  = capture_configuration
    @current_drift  = "" 
  end

  def run
    restore_configuration unless configuration_found
    compare_configuration
  end

  private

  def capture_configuration

    puppet_call(:notice, "Capturing current configuration...")

    json = []
    json.push({"name" => "ip address", "version" => facter_call(:ipaddress)})
    json.push({"name" => "mac address", "version" => facter_call(:macaddress)})

    packages = 
      if @os == 'darwin'
        out = `system_profiler SPApplicationsDataType`
        out.scan(/(.)+:(\s)+Version:(.)+/) {packages << $~}
      else
        out = (`#{@puppet_cmd} resource package`).split(/\n/)
        out.each_slice(3).map {|slice| slice.join("\n")}
      end
    
    packages.each {|package| json.push(extract_info_from package)}

    return JSON.generate({:packages => json})
  end
  
  def compare_configuration
    
    sum = Digest::MD5.file @config_file
    response = filebucket_request(:get, sum: sum)
    
    if(response.nil? || response.empty?)
      File.delete(@config_file)
      return
    end

    saved_configuration = JSON.parse(File.read(@config_file))
    current_configuration = JSON.parse(@configuration)
 
    if(current_configuration == saved_configuration)
      puppet_call(:notice, "No drift detected on #{@fqdn}.")
    
    else
      saved_array = saved_configuration["packages"].to_a
      current_array = current_configuration["packages"].to_a
      
      difference = (saved_array - current_array) + (current_array - saved_array)

      difference.each do |d|
        msg = "#{d["name"]} #{d["version"]}"

        if !(current_array.to_s.include? d.to_s)
          msg << " removed from #{@fqdn}"
        elsif !(saved_array.include? d)
          msg << " installed on #{@fqdn}"
        else
          current_array.each do |x|
            if(x["name"] == d["name"] && x["version"] != d["version"])
              msg << " replaced by #{x["name"]} #{x["version"]} on #{fqdn}"
            end
          end
        end

        msg << " after initial configuration capture."
        puppet_call(:notice, "#{msg}") unless msg.to_s.empty?
        @current_drift += msg.to_s unless(@current_drift.include?(msg.to_s))
      end

      prev_drift = facter_call(:drift) || ""
      prev_drift = @current_drift if prev_drift.strip.empty?

      msg = "Drift detected on #{@fqdn}."
      
      if (drift_changed?(prev_drift, @current_drift))
        puppet_call(:err, msg)
      else
        puppet_call(:warn, msg)
      end
      
      File.write(@drift_file, JSON.generate({:drift => @current_drift}))  
    end
  end
  
  def configuration_found
    File.exist? @config_file
  end

  def drift_changed?(d1, d2)
    !(d1.gsub(/\s/,"") == d2.gsub(/\s/, ""))
  end

  def extract_info_from pack
    return if pack.nil?

    name = 
      if @os == 'darwin'
        pack[/.*:/].tr!(':', "") 
      else
        pack[/\'.*\'/].tr!("'", "")
      end

    version = 
      if @os == 'darwin'
        pack[/Version:.*/].to_s.tr!("Version:", "") 
      else
        pack[/\'.*\',/].to_s.tr!("',", "")
      end
    
    return {"name" => name, "version" => version}
  end

  def facter_call val
    (Facter.value(val.to_sym))
  end
  
  def filebucket_request(type, file: "", sum: "")
    
    request = 
      case type
      when /get/
        "#{@puppet_cmd} filebucket get #{sum} --server #{@@SERVER}"
      when /restore/
        "#{@puppet_cmd} filebucket restore #{file} #{sum} --server #{@@SERVER}"
      when /local_backup/
        "#{@puppet_cmd} filebucket backup #{file} -l"
      when /remote_backup/
        "#{@puppet_cmd} filebucket backup #{file} --server #{@@SERVER}"
      when /list/ 
        "#{@puppet_cmd} filebucket -l list"
      end

    silence_output{`#{request}`}
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
  
  def restore_configuration
    list = filebucket_request(:list)
    restored = false
    unless(list.nil? || list.empty?)
      cached_files = list.split("\n")

      counter = 1.0
      size = cached_files.size
      puppet_call(:notice, "No configuration found at #{@config_file}. ")
      puppet_call(:notice, "Searching for cached configuration: ")
      
      cached_files.reverse_each do |line|
        next if(!(line.include? @config_file) || restored)
        
        progress = (((counter / size).round(2)) * 100).truncate
        puppet_call(:notice, "#{progress}%")
        counter += 1

        sum = line.split(" ")[0]
        response = filebucket_request(:get, sum: sum)

        unless(response.nil? || response.empty? || restored)

          restored = true
          filebucket_request(:restore, file: @config_file, sum: sum)
          puppet_call(:notice, "Restored #{@config_file} from #{@@SERVER} (#{sum})")
        end
      end 
    end

    if !(restored)
      save
      puppet_call(:notice, "No cached configuration found on server.")
      puppet_call(:notice, "Capturing a new configuration...")
    end
  end

  def save
    
    File.open(@config_file, 'w+') { |f| f.write(@configuration) }
    File.open(@drift_file, 'w+'){|f| f.write(JSON.generate({:drift =>@current_drift}))}  
    
    if configuration_found
      filebucket_request(:local_backup, file: @config_file)
      filebucket_request(:remote_backup, file: @config_file)
    end
  end
end

Configuration.new.run
