ENV["RAILS_ENV"] ||= "test"
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require "rspec/rails"

require File.dirname(__FILE__) + "/factories" unless defined?(Factory)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = true

  # a HTML helper
  def uploaded_html(path)
    fixture_file_upload(path, 'text/html')
  end

  # a JPEG helper
  def uploaded_jpeg(path)
    fixture_file_upload(path, 'image/jpeg')
  end
end
