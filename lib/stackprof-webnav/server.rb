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
        def render_with_layout *args
          args[0] = "views/#{args[0]}.haml"
          render('views/layout.haml') { render(*args) }
        end

        def presenter
          Server.presenter
        end

        def method_url name
          "/method?name=#{URI.escape(name)}"
        end
      end

      sprockets = Sprockets::Environment.new do |env|
        env.append_path('css')
      end
      builder.map('/assets'){ run sprockets }

      get '/' do
        @action = "overview"
        @frames = presenter.overview_frames
        render_with_layout :overview
      end

      get '/method' do
        @action = params[:name]
        @frames = presenter.method_info(params[:name])
        render_with_layout :method
      end
    end
  end
end
