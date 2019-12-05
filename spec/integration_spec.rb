require "spec_helper"

RSpec.describe "integration tests" do
  let(:presenter) { StackProf::Webnav::Server.presenter }
  let(:app) { make_app(filepath: fixture_path("test.dump")) }

  it "does not crash on overview page" do
    expect { app.get "/overview" }.to_not raise_error
  end

  it "does not crash on a method page" do
    frame = presenter.overview_frames.first

    expect {
      app.get "/method", name: frame[:method]
    }.to_not raise_error
  end

  it "does not crash on a file page" do
    frame = presenter.overview_frames.first
    method_info = presenter.method_info frame[:method]

    expect {
      app.get "/file", path: method_info.first[:location]
    }.to_not raise_error
  end
end
