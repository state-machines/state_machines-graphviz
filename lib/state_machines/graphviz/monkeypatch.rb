#TODO register graphviz as render engine
module StateMachines
  class Machine
    class << self
      # Draws the state machines defined in the given classes using GraphViz.
      # The given classes must be a comma-delimited string of class names.
      #
      # Configuration options:
      # * <tt>:file</tt> - A comma-delimited string of files to load that
      #   contain the state machine definitions to draw
      # * <tt>:path</tt> - The path to write the graph file to
      # * <tt>:format</tt> - The image format to generate the graph in
      # * <tt>:font</tt> - The name of the font to draw state names in
      def draw(class_names, options = {})
        raise ArgumentError, 'At least one class must be specified' unless class_names && class_names.split(',').any?

        # Load any files
        if files = options.delete(:file)
          files.split(',').each { |file| require file }
        end

        class_names.split(',').each do |class_name|
          # Navigate through the namespace structure to get to the class
          klass = Object
          class_name.split('::').each do |name|
            klass = klass.const_defined?(name) ? klass.const_get(name) : klass.const_missing(name)
          end

          # Draw each of the class's state machines
          klass.state_machines.each_value do |machine|
            machine.draw(options)
          end
        end
      end
    end

    # Draws a directed graph of the machine for visualizing the various events,
    # states, and their transitions.
    #
    # This requires both the Ruby graphviz gem and the graphviz library be
    # installed on the system.
    #
    # Configuration options:
    # * <tt>:name</tt> - The name of the file to write to (without the file extension).
    #   Default is "#{owner_class.name}_#{name}"
    # * <tt>:path</tt> - The path to write the graph file to.  Default is the
    #   current directory (".").
    # * <tt>:format</tt> - The image format to generate the graph in.
    #   Default is "png'.
    # * <tt>:font</tt> - The name of the font to draw state names in.
    #   Default is "Arial".
    # * <tt>:orientation</tt> - The direction of the graph ("portrait" or
    #   "landscape").  Default is "portrait".
    # * <tt>:human_names</tt> - Whether to use human state / event names for
    #   node labels on the graph instead of the internal name.  Default is false.
    def draw(graph_options = {})
      name = graph_options.delete(:name) || "#{owner_class.name}_#{self.name}"
      draw_options = {:human_name => false}
      draw_options[:human_name] = graph_options.delete(:human_names) if graph_options.include?(:human_names)

      graph = Graph.new(name, graph_options)

      # Add nodes / edges
      states.by_priority.each { |state| state.draw(graph, draw_options) }
      events.each { |event| event.draw(graph, draw_options) }

      # Output result
      graph.output
      graph
    end
  end

  class State
    # Draws a representation of this state on the given machine.  This will
    # create a new node on the graph with the following properties:
    # * +label+ - The human-friendly description of the state.
    # * +width+ - The width of the node.  Always 1.
    # * +height+ - The height of the node.  Always 1.
    # * +shape+ - The actual shape of the node.  If the state is a final
    #   state, then "doublecircle", otherwise "ellipse".
    #
    # Configuration options:
    # * <tt>:human_name</tt> - Whether to use the state's human name for the
    #   node's label that gets drawn on the graph
    def draw(graph, options = {})
      node = graph.add_nodes(name ? name.to_s : 'nil',
                             :label => description(options),
                             :width => '1',
                             :height => '1',
                             :shape => final? ? 'doublecircle' : 'ellipse'
      )

      # Add open arrow for initial state
      graph.add_edges(graph.add_nodes('starting_state', :shape => 'point'), node) if initial?

      true
    end
  end

  class Event
    # Draws a representation of this event on the given graph.  This will
    # create 1 or more edges on the graph for each branch (i.e. transition)
    # configured.
    #
    # Configuration options:
    # * <tt>:human_name</tt> - Whether to use the event's human name for the
    #   node's label that gets drawn on the graph
    def draw(graph, options = {})
      valid_states = machine.states.by_priority.map {|state| state.name}
      branches.each do |branch|
        branch.draw(graph, options[:human_name] ? human_name : name, valid_states)
      end

      true
    end
  end

  class Branch
    # Draws a representation of this branch on the given graph.  This will draw
    # an edge between every state this branch matches *from* to either the
    # configured to state or, if none specified, then a loopback to the from
    # state.
    #
    # For example, if the following from states are configured:
    # * +idling+
    # * +first_gear+
    # * +backing_up+
    #
    # ...and the to state is +parked+, then the following edges will be created:
    # * +idling+      -> +parked+
    # * +first_gear+  -> +parked+
    # * +backing_up+  -> +parked+
    #
    # Each edge will be labeled with the name of the event that would cause the
    # transition.
    def draw(graph, event, valid_states)
      state_requirements.each do |state_requirement|
        # From states determined based on the known valid states
        from_states = state_requirement[:from].filter(valid_states)

        # If a to state is not specified, then it's a loopback and each from
        # state maps back to itself
        if state_requirement[:to].values.empty?
          loopback = true
        else
          to_state = state_requirement[:to].values.first
          to_state = to_state ? to_state.to_s : 'nil'
          loopback = false
        end

        # Generate an edge between each from and to state
        from_states.each do |from_state|
          from_state = from_state ? from_state.to_s : 'nil'
          graph.add_edges(from_state, loopback ? from_state : to_state, :label => event.to_s)
        end
      end

      true
    end
  end
end