require 'sinatra'
require 'haml'
require "stackprof"
require 'net/http'
require_relative 'presenter'

module StackProf
  module Webnav
    class Server < Sinatra::Application
      class << self
        attr_accessor :cmd_options, :report_dump_path, :report_dump_uri, :report_dump_listing

        def presenter regenerate=false
          return @presenter unless regenerate || @presenter.nil?
          process_options
          if self.report_dump_path || self.report_dump_uri
            report_contents = if report_dump_path.nil?
                                Net::HTTP.get(URI.parse(report_dump_uri))
                              else
                                File.open(report_dump_path).read
                              end
            report = StackProf::Report.new(Marshal.load(report_contents))
          end
          @presenter = Presenter.new(report)
        end

        private
        def process_options
          if cmd_options[:filepath]
            self.report_dump_path = cmd_options[:filepath]
          elsif cmd_options[:uri]
            self.report_dump_uri = cmd_options[:uri]
          elsif cmd_options[:bucket]
            self.report_dump_listing = cmd_options[:bucket]
          end
        end

      end

      helpers do
        def presenter
          Server.presenter
        end

        def method_url name
          "/method?name=#{URI.escape(name)}"
        end

        def file_url path
          "/file?path=#{URI.escape(path)}"
        end

        def overview_url path
          "/overview?path=#{URI.escape(path)}"
        end
      end

      get '/' do
        presenter
        if Server.report_dump_listing
          redirect '/listing'
        else
          redirect '/overview'
        end
      end

      get '/overview' do
        if params[:path]
          Server.report_dump_uri = params[:path]
          Server.presenter(true)
        end
        @file = Server.report_dump_path || Server.report_dump_uri
        @action = "overview"
        @frames = presenter.overview_frames
        haml :overview
      end

      get '/listing' do
        @file = Server.report_dump_listing
        @action = "listing"
        @dumps = presenter.listing_dumps
        haml :listing
      end

      get '/method' do
        @action = params[:name]
        @frames = presenter.method_info(params[:name])
        haml :method
      end

      get '/file' do
        path = params[:path]

        if File.exist?(path)
          @path = path
          @data = presenter.file_overview(path)
        else
          @data = nil
        end

        haml :file
      end
    end
  end
end
