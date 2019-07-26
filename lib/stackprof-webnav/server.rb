require 'sinatra'
require 'haml'
require "stackprof"
require 'net/http'
require_relative 'presenter'
require 'pry'
require "sinatra/reloader" if development?
require 'ruby-graphviz'

class Dump
  attr_reader :path
  attr_accessor :flamegraph_json, :graph_data
  def initialize(path)
    @path = path
  end

  def checksum
    @checksum ||= Digest::SHA1.file(@path)
  end

  def content
    @content ||= File.open(@path).read
  end
end

module StackProf
  module Webnav
    class Server < Sinatra::Application
      class << self
        attr_accessor :cmd_options
      end

      configure :development do
        register Sinatra::Reloader
      end

      helpers do
        def current_dump
          Thread.current[:dump] ||= Dump.new(params[:dump])
        end

        def current_report
          Thread.current[:report] ||= StackProf::Report.new(
            Marshal.load(current_dump.content)
          )
        end

        def presenter
          Thread.current[:presenter] ||= Presenter.new(current_report)
        end

        def string_io(&block)
          io = StringIO.new
          yield io
          io.close
          io.string
        end

        def url_for(path, options={})
          query = URI.encode_www_form({dump: params[:dump]}.merge(options))
          path + "?" + query
        end
      end

      get '/' do
        @directory = File.expand_path(Server.cmd_options[:directory] || '.')
        @files = Dir.entries(@directory).map do |file|
          OpenStruct.new(name: file, path: File.expand_path(file, @directory))
        end.select do |file|
          File.file?(file.path)
        end

        haml :index
      end

      get '/overview' do
        @action = "overview"
        @frames = presenter.overview_frames
        haml :overview
      end

      get '/flames.json' do
        current_dump.flamegraph_json ||= string_io do |io|
          current_report.print_flamegraph(io)
        end

        content_type :js
        current_dump.flamegraph_json
      end

      get '/graph.png' do
        current_dump.graph_data ||= string_io do |io|
          current_report.print_graphviz({}, io)
        end

        image_path = "/tmp/graph.png"

        unless File.exist?(image_path)
          GraphViz.parse_string(current_dump.graph_data).output(png: image_path)
        end

        content_type :png
        File.read(image_path)
      end

      get '/graph' do
        haml :graph
      end

      get '/flamegraph' do
        haml :flamegraph, layout: false
      end

      get '/method' do
        @action = params[:name]
        @frames = presenter.method_info(params[:name])
        haml :method
      end

      get '/file' do
        path = params[:path]
        @path = path
        @data = presenter.file_overview(path)
        haml :file
      end
    end
  end
end
