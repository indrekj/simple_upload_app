# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
require 'spec/autorun'
require 'spec/rails'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  config.include FixtureReplacement

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
