# http://backbonedocs.drop.io/Ruby-API-Client-Library
config = YAML.load_file(Rails.root.to_s + "/config/dropio.yml")

Dropio::Config.api_key = config[:key]
Dropio::Config.api_secret = config[:secret]
Dropio::Config.version = "3.0"
