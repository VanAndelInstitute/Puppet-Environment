def valid_fqdn(fqdn)
    return (fqdn.include? ("cryo") or fqdn.include? ("gongpu"))
end
