require "spec_helper"

RSpec.describe "integration tests" do
  let(:app) { build_app }
  let(:presenter) { build_presenter(fixture_path("test.dump")) }
  let(:response) { app.last_response }

  after(:each) do
    Dir.glob("spec/fixtures/*.flames.json").each {|file| File.delete(file) }
    Dir.glob("spec/fixtures/*.digraph.dot").each {|file| File.delete(file) }
    Dir.glob("spec/fixtures/*.graph.svg").each {|file| File.delete(file) }
  end

  describe "index" do
    it "lists the files in a folder" do
      app = build_app(directory: "spec/fixtures")
      app.get "/"
      expect(app.last_response.body).to include("test.dump")
    end

    it "redirects to overview if path is specified" do
      app = build_app(filepath: fixture_path("test.dump"))
      app.get "/"
      app.follow_redirect!
      expect(app.last_response.body).to include("Dummy")
    end
  end

  it "does not crash on unknown requests" do
    app.get "/favicon.ico"
    expect(response.status).to eq(404)
  end

  describe "overview" do
    it "works with a valid dump" do
      app.get "/overview", dump: fixture_path("test.dump")

      frame = presenter.overview_frames.first
      expect(response.body).to include(frame[:method])
    end

    it "communicates that flamegraph is not available for dump" do
      app.get "/overview", dump: fixture_path("test.dump")
    end

    it "does not crash if selected file is not a dump" do
      app.get "/overview", dump: "Rakefile"
      expect(response.body).to include("Unable to open")
    end
  end

  it "is able to generate flames.json file" do
    app.get "/flames.json", dump: fixture_path("test-raw.dump")
    expect(response.body).to include("flamegraph")
  end

  it "is able to render graph" do
    app.get "/graph.svg", dump: fixture_path("test.dump")
    expect(response.get_header("Content-Type")).to eq("image/svg+xml")
    expect(response.body.size).to_not eq(0)
  end

  it "method page renders information about a method" do
    frame = presenter.overview_frames.first
    app.get "/method", dump: fixture_path("test.dump"), name: frame[:method]
    expect(response.body).to include("Callers")
  end

  it "does not crash on a file page" do
    frame = presenter.overview_frames.first
    method_info = presenter.method_info frame[:method]

    expect {
      app.get "/file",
        dump: fixture_path("test.dump"),
        path: method_info.first[:location]
    }.to_not raise_error
  end
end
