# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = "2.3.5" unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), "boot")

Rails::Initializer.run do |config|
  config.gem "sqlite3-ruby", :lib => "sqlite3"
  config.gem "rspec", :lib => false
  config.gem "rspec-rails", :lib => false
  config.gem "hpricot"
  config.gem "rack"

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  config.frameworks -= [ :action_mailer ]

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = "Tallinn"

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :et

  # Middleware
  config.middleware.use "Rack::JSONP"
end
