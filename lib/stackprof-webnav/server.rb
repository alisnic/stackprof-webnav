require 'sinatra'
require 'haml'
require 'stackprof'
require_relative 'presenter'
require_relative 'dump'
require 'sinatra/reloader' if development?
require 'ruby-graphviz'

module StackProf
  module Webnav
    class Server < Sinatra::Application
      class << self
        attr_accessor :cmd_options
      end

      configure :development do
        register Sinatra::Reloader
      end

      configure :production do
        set :show_exceptions, false
      end

      error do
        @error = env['sinatra.error']
        haml :error
      end

      before do
        unless request.path_info == '/'
          if params[:dump] && params[:dump] != current_dump.path
            current_dump.path = params[:dump]
          end
        end
      end

      helpers do
        def current_dump
          Thread.current[:cache] = {}
          Thread.current[params[:dump]] ||= Dump.new(params[:dump])
        end

        def current_report
          StackProf::Report.new(
            Marshal.load(current_dump.content)
          )
        end

        def presenter
          Presenter.new(current_report)
        end

        def ensure_file_generated(path, &block)
          return if File.exist?(path)
          File.open(path, 'wb', &block)
        end

        def url_for(path, options={})
          query = URI.encode_www_form({dump: params[:dump]}.merge(options))
          path + "?" + query
        end
      end

      get '/' do
        if Server.cmd_options[:filepath]
          query = URI.encode_www_form(dump: Server.cmd_options[:filepath])
          next redirect to("/overview?#{query}")
        end

        @directory = File.expand_path(Server.cmd_options[:directory] || '.')
        @files = Dir.entries(@directory).sort.map do |file|
          path = File.expand_path(file, @directory)

          OpenStruct.new(
            name: file,
            path: path,
            modified: File.mtime(path)
          )
        end.select do |file|
          File.file?(file.path)
        end

        haml :index
      end

      get '/overview' do
        @action = "overview"

        begin
          @frames = presenter.overview_frames
          haml :overview
        rescue => error
          haml :invalid_dump
        end
      end

      get '/flames.json' do
        ensure_file_generated(current_dump.flame_graph_path) do |file|
          current_report.print_flamegraph(file, true, true)
        end

        send_file(current_dump.flame_graph_path, type: 'text/javascript')
      end

      get '/graph.svg' do
        ensure_file_generated(current_dump.graph_path) do |file|
          current_report.print_graphviz({}, file)
        end

        ensure_file_generated(current_dump.graph_image_path) do |file|
          GraphViz
            .parse(current_dump.graph_path)
            .output(svg: current_dump.graph_image_path)
        end

        send_file(current_dump.graph_image_path, type: 'image/svg+xml')
      end

      get '/graph' do
        haml :graph
      end

      get '/flamegraph' do
        haml :flamegraph
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
