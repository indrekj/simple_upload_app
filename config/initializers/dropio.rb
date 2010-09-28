# http://backbonedocs.drop.io/Ruby-API-Client-Library
config = YAML.load_file(Rails.root.to_s + "/config/dropio.yml")
Dropio::Config.api_key = config[:key]
