master_hash = {}
license_hash = YAML.load_file('config/authorities/licenses.yml')
license_hash["terms"].each do |ele|
  master_hash[ele["id"]] = ele["term"]
end
master_hash

MASTER_LICENSE_HASH = master_hash
