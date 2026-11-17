# frozen_string_literal: true

require 'state_machines-diagram'

module StateMachines
  module Graphviz
    # Draws a machine, or the part of it one state, event or branch involves,
    # with GraphViz. What is drawn comes from StateMachines::Diagram::Builder:
    # its states and markers, the transitions the core performs, their guards
    # and the callbacks that run on them.
    module Renderer
      # The start point's node id: the diagram's terminal pseudo-state, which
      # Builder.state_id never gives a state
      START_NODE_ID = ::Diagrams::StateDiagram::TERMINAL
      # Characters DOT reads as escapes or breaks in a quoted id; ruby-graphviz
      # writes ids holding them as they are
      UNSAFE_ID = /[\\[:cntrl:]]/
      # Characters ruby-graphviz writes into a label as they are, so DOT would
      # read them as escapes (\N, \n, ...) or the label as HTML (<...>)
      LABEL_ESCAPES = /[\\<]/

      extend self

      # Draws the whole machine and writes the graph's file
      def draw_machine(machine, **options)
        graph_options = options.dup
        name = graph_options.delete(:name) || "#{machine.owner_class.name}_#{machine.name}"
        human_names = graph_options.delete(:human_names)
        graph = Graph.new(name, graph_options)

        builder = Diagram::Builder.new(machine, human_names: human_names)
        builder.build
        draw_built(graph, builder)
        graph.output
        graph
      end

      # Adds the state's node, and the start point if it is the initial state
      def draw_state(state, graph, options = {}, _io = $stdout)
        builder = Diagram::Builder.new(state.machine, human_names: options[:human_name])
        builder.build_state(state)
        add_state_node(graph, builder, state)
        graph
      end

      # Adds the transitions the event performs and the states they connect
      def draw_event(event, graph, options = {}, _io = $stdout)
        builder = Diagram::Builder.new(event.machine, human_names: options[:human_name])
        builder.build_event(event)
        draw_built(graph, builder)
        graph
      end

      # Adds the transitions one branch performs and the states they connect.
      # The core passes no options (Branch#draw).
      def draw_branch(branch, graph, event, _valid_states, _io = $stdout)
        builder = Diagram::Builder.new(event.machine)
        builder.build_branch(branch, event)
        draw_built(graph, builder)
        graph
      end

      # The node id of the state with diagram id +state_id+. An id DOT would
      # misread is drawn by its bytes in hex, as Builder.state_id escapes ids:
      # the builder only escapes names that hold none of those characters,
      # so the two never meet.
      def node_id(state_id)
        state_id.match?(UNSAFE_ID) ? "%#{state_id.unpack1('H*')}" : state_id
      end

      private

      # The guards a transition runs under, as one bracketed condition:
      # "[if ready? && if_state gate=open]"
      def guard_label(conditions)
        phrases = Diagram::Labels.condition_phrases(conditions)
        "[#{phrases.join(' && ')}]" unless phrases.empty?
      end

      def draw_built(graph, builder)
        states = Diagram::Introspection.states_of(builder.machine).to_h { [Diagram::Builder.state_id(it.name), it] }
        nodes = builder.diagram.states.to_h { [it.id, add_state_node(graph, builder, states.fetch(it.id))] }

        builder.transition_metadata.each do |metadata|
          transition = metadata[:transition]
          add_transition_edge(graph, nodes.fetch(transition.source_state_id),
                              nodes.fetch(transition.target_state_id), metadata)
        end
      end

      # The state's node: a double circle for a final state, an edge from
      # the start point for the initial one (a state can be both)
      def add_state_node(graph, builder, state)
        id = Diagram::Builder.state_id(state.name)
        metadata = builder.state_metadata.fetch(id)
        node = graph.add_nodes(
          node_id(id),
          label: dot_text([node_label(state, metadata[:label])]),
          width: '1',
          height: '1',
          shape: metadata[:final] ? 'doublecircle' : 'ellipse'
        )
        graph.add_edges(graph.add_nodes(START_NODE_ID, shape: 'point'), node) if metadata[:initial]
        node
      end

      # The state's label and, as State#description shows it, its value
      # when that is not its name: "parked (1)", "idling (*)" for a lambda
      def node_label(state, label)
        value = state.value(false)
        return label if state.name.to_s == value.to_s

        "#{label} (#{value.is_a?(Proc) ? '*' : value.inspect})"
      end

      # The event and its guards over the edge. The callbacks in the order the
      # core runs them (Introspection.callback_sequence): those that run
      # before the state changes at the edge's tail, before and around
      # callbacks in declaration order with an around where it enters (as
      # Labels.action_list lists it), the after callbacks at its head
      def add_transition_edge(graph, from, to, metadata)
        sequence = metadata[:callback_sequence].reject { it[:phase] == :exit }
        after, before = sequence.partition { it[:kind] == :after }
        graph.add_edges(
          from,
          to,
          label: dot_text([metadata[:label], guard_label(metadata[:conditions])]),
          labelfontsize: 10,
          taillabel: dot_text(before.map { it[:text] }),
          headlabel: dot_text(after.map { it[:text] })
        )
      end

      # Lines of label text as DOT shows them as they are
      def dot_text(lines)
        lines.compact.map { |line| line.gsub(LABEL_ESCAPES) { "\\#{it}" } }.join("\n")
      end
    end
  end
end
