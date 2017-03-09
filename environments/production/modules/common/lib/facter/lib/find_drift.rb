def find_drift c, s, d
    # A previously installed package was not found in the current configuration
    if !(c.to_s.include? d.to_s); msg = d["name"] + " " + d["version"] + " not found on #$fqdn."
    
    # A package was installed after the configuration was retrieved initially.
    elsif !(s.to_s.include? d.to_s); msg = d["name"] + " " + d["version"] + " installed on #$fqdn after configuration."
    
    # The found package version differs from the saved package version.
    else; c.each {(msg = x["name"] + " " + x["version"] + " should be " + d["name"] + " " + d["version"] + ".") if x["name"] == d["name"] and x["version"] != d["version"]}
    end 

    [msg,true]
end

