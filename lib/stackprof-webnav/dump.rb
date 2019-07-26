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

  def flame_graph_path
    @path + ".#{checksum}.flames.json"
  end

  def graph_path
    @path + ".#{checksum}.digraph.dot"
  end

  def graph_image_path
    @path + ".#{checksum}.graph.png"
  end
end
