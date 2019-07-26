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

  def path=(new_path)
    @path = new_path
    check_checksum!
  end

  def check_checksum!
    return unless @checksum

    if Digest::SHA1.file(@path) != checksum
      puts "\n\nFile reloaded"
      @checksum, @content = nil, nil
    end
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
