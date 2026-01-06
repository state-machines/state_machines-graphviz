# frozen_string_literal: true

require 'state_machines/diagram/renderer'

module StateMachines
  module Graphviz
    module Renderer
      extend self

      VALID_OPTIONS = %i[
        name
        path
        format
        font
        orientation
        human_name
        human_names
        io
        show_conditions
        show_callbacks
      ].freeze

      def draw_machine(machine, io: $stdout, **options)
        validate_options!(options)
        diagram, builder = StateMachines::Diagram::Renderer.build_state_diagram(machine, options)
        graph = build_graph(machine, diagram, builder, options)
        graph.output
        graph
      end

      def draw_state(state, graph, options = {}, io = $stdout)
        validate_options!(options)
        add_state_node(state, graph, options)
        graph
      end

      def draw_event(event, graph, options = {}, io = $stdout)
        validate_options!(options)
        machine = event.machine
        valid_states = machine.states.by_priority.map(&:name)

        event.branches.each do |branch|
          draw_branch(branch, graph, event, valid_states, io, options)
        end

        graph
      end

      def draw_branch(branch, graph, event, valid_states, io = $stdout, options = {})
        validate_options!(options)
        machine = event.machine
        event_label = human_names?(options) ? event.human_name(machine.owner_class) : event.name.to_s

        branch.state_requirements.each do |state_requirement|
          from_states = state_requirement[:from].filter(valid_states)

          if state_requirement[:to].values.empty?
            loopback = true
          else
            to_state = state_requirement[:to].values.first
            to_state = to_state ? to_state.to_s : 'nil'
            loopback = false
          end

          from_states.each do |from_state|
            from_state = from_state ? from_state.to_s : 'nil'
            graph.add_edges(
              from_state,
              loopback ? from_state : to_state,
              edge_options(event_label, branch: branch, event: event, machine: machine, options: options)
            )
          end
        end

        graph
      end

      private

      def validate_options!(options)
        StateMachines::OptionsValidator.assert_valid_keys!(options, *VALID_OPTIONS)
      end

      def build_graph(machine, diagram, builder, options)
        graph = StateMachines::Graph.new(graph_name(machine, options), graph_options(options))
        populate_graph(graph, machine, diagram, builder, options)
        graph
      end

      def populate_graph(graph, machine, diagram, builder, options)
        state_lookup = build_state_lookup(machine)
        start_node = nil

        diagram.states.each do |state_node|
          state = state_lookup[state_node.id]
          metadata = builder&.state_metadata&.[](state_node.id) || {}
          shape = metadata[:type] == 'final' ? 'doublecircle' : 'ellipse'
          label = state ? state.description(human_name: human_names?(options)) : (state_node.label || state_node.id)

          node = graph.add_nodes(
            state_node.id,
            label: label,
            width: '1',
            height: '1',
            shape: shape
          )

          if metadata[:type] == 'initial'
            start_node ||= graph.add_nodes('starting_state', shape: 'point')
            graph.add_edges(start_node, node)
          end
        end

        transition_map = transition_metadata_map(builder)
        diagram.transitions.each do |transition|
          metadata = transition_map[transition]
          graph.add_edges(
            transition.source_state_id,
            transition.target_state_id,
            edge_options(transition.label, metadata: metadata, options: options)
          )
        end
      end

      def build_state_lookup(machine)
        machine.states.each_with_object({}) do |state, memo|
          key = state.name ? state.name.to_s : 'nil_state'
          memo[key] = state
        end
      end

      def graph_name(machine, options)
        options[:name] || "#{machine.owner_class.name}_#{machine.name}"
      end

      def graph_options(options)
        options.slice(:path, :format, :font, :orientation)
      end

      def transition_metadata_map(builder)
        Array(builder&.transition_metadata).each_with_object({}) do |metadata, memo|
          transition = metadata[:transition]
          memo[transition] = metadata if transition
        end
      end

      def edge_options(label, metadata: nil, branch: nil, event: nil, machine: nil, options: {})
        edge_options = { labelfontsize: 10 }

        label_text = label.to_s if label
        label_text = nil if label_text&.empty?

        if options[:show_conditions] && metadata
          condition_tokens = build_condition_tokens(metadata[:conditions])
          unless condition_tokens.empty?
            guard_fragment = "[#{condition_tokens.join(' && ')}]"
            label_text = label_text ? "#{label_text} #{guard_fragment}" : guard_fragment
          end
        end

        if options[:show_callbacks]
          callbacks = metadata ? metadata[:callbacks] : branch_callbacks(branch, event, machine)
          label_text = append_around_callbacks(label_text, callbacks)
          edge_options[:taillabel] = callback_label(callbacks, :before) if callback_label(callbacks, :before)
          edge_options[:headlabel] = callback_label(callbacks, :after) if callback_label(callbacks, :after)
        end

        edge_options[:label] = label_text if label_text
        edge_options
      end

      def build_condition_tokens(conditions)
        return [] unless conditions.is_a?(Hash)

        tokens = []
        Array(conditions[:if]).each do |token|
          next if token.nil? || token.to_s.empty?
          tokens << "if #{token}"
        end
        Array(conditions[:unless]).each do |token|
          next if token.nil? || token.to_s.empty?
          tokens << "unless #{token}"
        end
        tokens
      end

      def branch_callbacks(branch, event, machine)
        return {} unless branch && event && machine

        {
          before: callback_method_names(machine, branch, event, :before),
          after: callback_method_names(machine, branch, event, :after),
          around: callback_method_names(machine, branch, event, :around)
        }
      end

      def callback_method_names(machine, branch, event, type)
        machine.callbacks[type == :around ? :before : type].select do |callback|
          callback.branch.matches?(branch,
                                   from: branch.state_requirements.map { |req| req[:from] },
                                   to: branch.state_requirements.map { |req| req[:to] },
                                   on: event.name)
        end.flat_map do |callback|
          callback.instance_variable_get('@methods')
        end.compact
      end

      def callback_label(callbacks, type)
        return nil unless callbacks.is_a?(Hash)

        names = Array(callbacks[type]).compact
        return nil if names.empty?

        names.join("\n")
      end

      def append_around_callbacks(label_text, callbacks)
        return label_text unless callbacks.is_a?(Hash)

        around = Array(callbacks[:around]).compact
        return label_text if around.empty?

        around_fragment = "around #{around.join(', ')}"
        label_text ? "#{label_text} / #{around_fragment}" : around_fragment
      end

      def add_state_node(state, graph, options)
        human_name = human_names?(options)
        node = graph.add_nodes(
          state.name ? state.name.to_s : 'nil',
          label: state.description(human_name: human_name),
          width: '1',
          height: '1',
          shape: state.final? ? 'doublecircle' : 'ellipse'
        )

        graph.add_edges(graph.add_nodes('starting_state', shape: 'point'), node) if state.initial?
        node
      end

      def human_names?(options)
        options[:human_name] || options[:human_names]
      end
    end
  end
end
