ENV["RAILS_ENV"] ||= "test"
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require "rspec/rails"

require File.dirname(__FILE__) + "/factories" unless defined?(Factory)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  # == Mock Framework
  #
  # config.mock_with :mocha
  config.mock_with :rspec

  # get us an object that represents an uploaded file
  def uploaded_file(path, content_type = 'application/octet-stream', filename = nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    t
  end

  # a HTML helper
  def uploaded_html(path, filename = nil)
    uploaded_file(path, 'text/html', filename)
  end

  # a JPEG helper
  def uploaded_jpeg(path, filename = nil)
    uploaded_file(path, 'image/jpeg', filename)
  end
end
