require 'nyny'
require 'haml'
require "stackprof"
require 'sprockets'
require_relative 'presenter'

module StackProf
  module Webnav
    class Server < NYNY::App
      class << self
        attr_accessor :report_dump_path

        def presenter
          report = StackProf::Report.new(Marshal.load(File.open(report_dump_path).read))
          @presenter ||= Presenter.new(report)
        end
      end

      helpers do
        def template_path name
          File.join(__dir__, name)
        end

        def render_with_layout *args
          args[0] = template_path("views/#{args[0]}.haml")
          render(template_path('views/layout.haml')) { render(*args) }
        end

        def presenter
          Server.presenter
        end

        def method_url name
          "/method?name=#{URI.escape(name)}"
        end

        def file_url path
          "/file?path=#{URI.escape(path)}"
        end
      end

      sprockets = Sprockets::Environment.new do |env|
        env.append_path(File.join(__dir__, 'css'))
      end
      builder.map('/assets'){ run sprockets }

      get '/' do
        @file = Server.report_dump_path
        @action = "overview"
        @frames = presenter.overview_frames
        render_with_layout :overview
      end

      get '/method' do
        @action = params[:name]
        @frames = presenter.method_info(params[:name])
        render_with_layout :method
      end

      get '/file' do
        path = params[:path]
        @path = path
        @data = presenter.file_overview(path)
        render_with_layout :file
      end
    end
  end
end
