require 'nyny'
require 'haml'
require "stackprof"
require 'sprockets/nyny'
require 'net/http'
require_relative 'presenter'

module StackProf
  module Webnav
    class Server < NYNY::App
      register Sprockets::NYNY
      config.assets.paths << File.join(__dir__, 'css'))

      class << self
        attr_accessor :report_dump_path, :report_dump_url

        def presenter
          return @presenter unless @presenter.nil?
          content = if report_dump_path.nil?
                      Net::HTTP.get(URI.parse(report_dump_url))
                    else
                      File.open(report_dump_path).read

          report = StackProf::Report.new(Marshal.load(content))
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

      get '/' do
        @file = Server.report_dump_path || Server.report_dump_url
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
