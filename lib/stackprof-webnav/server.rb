require 'nyny'
require 'haml'
require "stackprof"
require 'sprockets'
require_relative 'stackprof_presenter'

class App < NYNY::App
  report    = StackProf::Report.new(Marshal.load(File.open('test.dump').read))
  presenter = StackProfPresenter.new(report)

  helpers do
    def render_with_layout *args
      args[0] = "views/#{args[0]}.haml"
      render('views/layout.haml') { render(*args) }
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

App.run!