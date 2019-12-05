require 'rack/test'

module Helpers
  def make_app(options={})
    StackProf::Webnav::Server.cmd_options = options
    Rack::Test::Session.new(Rack::MockSession.new(StackProf::Webnav::Server))
  end

  def fixture_path(name)
    File.join(File.dirname(__FILE__), "fixtures", name)
  end
end
