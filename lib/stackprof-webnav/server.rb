require 'sinatra'
require 'haml'
require "stackprof"
require 'net/http'
require_relative 'presenter'
require 'pry'

module StackProf
  module Webnav
    class Server < Sinatra::Application
      class << self
        attr_accessor :cmd_options
      end

      helpers do
        def current_dump
          File.open(params[:dump]).read
        end

        def current_report
          StackProf::Report.new(Marshal.load(current_dump))
        end

        def presenter
          Thread.current[:presenter] ||= Presenter.new(current_report)
        end

        def flamegraph_url
          "/flamegraph?dump=#{URI.escape(params[:dump])}"
        end

        def method_url name
          "/method?dump=#{URI.escape(params[:dump])}&name=#{URI.escape(name)}"
        end

        def file_url path
          "/file?dump=#{URI.escape(params[:dump])}&path=#{URI.escape(path)}"
        end

        def overview_url path
          "/overview?dump=#{URI.escape(path)}"
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
        @file = params[:dump]
        @action = "overview"
        @frames = presenter.overview_frames
        haml :overview
      end

      get '/flames.json' do
        checksum = Digest::SHA1.file(params[:dump])
        flames   = "/tmp/flames-#{checksum}.json"

        unless File.exist?(flames)
          puts "GENERATING FLAMES BOI"
          f = File.open(flames, 'wb')
          current_report.print_flamegraph(f)
          f.close
        end

        content_type :js
        File.read(flames)
      end

      get '/flamegraph' do
        checksum = Digest::SHA1.file(params[:dump])
        flames   = "/tmp/flames-#{checksum}.json"

        @json_path = flames

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
