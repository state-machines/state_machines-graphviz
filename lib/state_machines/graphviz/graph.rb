module StateMachines
  # Provides a set of higher-order features on top of the raw GraphViz graphs
  class Graph < GraphViz
    # The name of the font to draw state names in
    attr_reader :font

    # The graph's full filename
    attr_reader :file_path

    # The image format to generate the graph in
    attr_reader :file_format

    # Creates a new graph with the given name.
    #
    # Configuration options:
    # * <tt>:path</tt> - The path to write the graph file to.  Default is the
    #   current directory (".").
    # * <tt>:format</tt> - The image format to generate the graph in.
    #   Default is "png'.
    # * <tt>:font</tt> - The name of the font to draw state names in.
    #   Default is "Arial".
    # * <tt>:orientation</tt> - The direction of the graph ("portrait" or
    #   "landscape").  Default is "portrait".
    def initialize(name, options = {})
      options = { path: 'doc/state_machines', format: 'png', font: 'Arial', orientation: 'portrait' }.merge(options)
      options.assert_valid_keys(:path, :format, :font, :orientation)

      # TODO fail if path cannot be created or readonly
      unless Dir.exist? options[:path]
        FileUtils.mkpath(options[:path])
      end
      @font = options[:font]
      @file_path = File.join(options[:path], "#{name}.#{options[:format]}")
      @file_format = options[:format]

      super('G', rankdir: options[:orientation] == 'landscape' ? 'LR' : 'TB')
    end

    # Generates the actual image file based on the nodes / edges added to the
    # graph.  The path to the file is based on the configuration options for
    # this graph.
    def output
      super(@file_format => @file_path)
    end

    # Adds a new node to the graph.  The font for the node will be automatically
    # set based on the graph configuration.  The generated node will be returned.
    #
    # For example,
    #
    #   graph = StateMachines::Graph.new('test')
    #   graph.add_nodes('parked', :label => 'Parked', :width => '1', :height => '1', :shape => 'ellipse')
    def add_nodes(*args)
      node = super
      node.fontname = @font
      node
    end

    # Adds a new edge to the graph.  The font for the edge will be automatically
    # set based on the graph configuration.  The generated edge will be returned.
    #
    # For example,
    #
    #   graph = StateMachines::Graph.new('test')
    #   graph.add_edges('parked', 'idling', :label => 'ignite')
    def add_edges(*args)
      edge = super
      edge.fontname = @font
      edge
    end
  end
end
