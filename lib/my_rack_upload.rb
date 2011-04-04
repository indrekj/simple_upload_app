module Rack
  class MyRackUpload
    def initialize(app)
      @app = app
      @tmpdir = Dir::tmpdir
    end

    def call(env)
      kick_in?(env) ? convert_and_pass_on(env) : @app.call(env)
    end

    private

    def convert_and_pass_on(env)
      tempfile = Tempfile.new('raw-upload.', @tmpdir)
      tempfile = open(tempfile.path, "r+:BINARY")
      tempfile << env['rack.input'].read
      tempfile.flush
      tempfile.rewind
      fake_file = {
        :filename => env['HTTP_X_FILE_NAME'],
        :type => env['CONTENT_TYPE'],
        :tempfile => tempfile,
      }
      env['rack.request.form_input'] = env['rack.input']
      env['rack.request.form_hash'] ||= {}
      env['rack.request.query_hash'] ||= {}
      env['rack.request.form_hash']['file'] = fake_file
      env['rack.request.query_hash']['file'] = fake_file
      if query_params = env['HTTP_X_QUERY_PARAMS']
        require 'json'
        params = JSON.parse(query_params)
        env['rack.request.form_hash'].merge!(params)
        env['rack.request.query_hash'].merge!(params)
      end
      @app.call(env)
    end

    def kick_in?(env)
      env['HTTP_X_FILE_NAME'] && env['REQUEST_METHOD'] == 'POST'
    end
  end
end
