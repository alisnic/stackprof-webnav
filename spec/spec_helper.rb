ENV['APP_ENV'] = 'test'
$LOAD_PATH.unshift File.join(Dir.pwd, "lib")

require "stackprof-webnav"
require "rspec"
require_relative 'helpers'

RSpec.configure do |config|
  config.include Helpers
  config.backtrace_exclusion_patterns << /.gem/

  config.after(:each) do
    StackProf::Webnav::Server.cmd_options = {}
  end
end
