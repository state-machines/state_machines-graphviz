# frozen_string_literal: true

require 'state_machines-diagram'

module StateMachines
  module Graphviz
    module Renderer
      extend self

      def draw_machine(machine, io: $stdout, **options)
        diagram, builder = StateMachines::Diagram::Renderer.build_state_diagram(machine, options)
        graph_options = options.dup
        name = graph_options.delete(:name) || "#{machine.owner_class.name}_#{machine.name}"

        draw_options = { human_name: false }
        draw_options[:human_name] = graph_options.delete(:human_names) if graph_options.include?(:human_names)

        graph = Graph.new(name, graph_options)
        render_diagram(graph, diagram, builder, draw_options)
        graph.output
        graph
      end

      def draw_state(state, graph, options = {}, io = $stdout)
        node = graph.add_nodes(
          state.name ? state.name.to_s : 'nil',
          label: state.description(options),
          width: '1',
          height: '1',
          shape: state.final? ? 'doublecircle' : 'ellipse'
        )

        graph.add_edges(graph.add_nodes('starting_state', shape: 'point'), node) if state.initial?
        true
      end

      def draw_event(event, graph, options = {}, io = $stdout)
        machine = event.machine
        valid_states = machine.states.by_priority.map(&:name)
        event_label = options[:human_name] ? event.human_name(machine.owner_class) : event.name.to_s

        event.branches.each do |branch|
          draw_branch_with_label(branch, graph, event_label, machine, valid_states)
        end

        true
      end

      def draw_branch(branch, graph, event, valid_states, io = $stdout)
        machine = event.machine
        draw_branch_with_label(branch, graph, event.name.to_s, machine, valid_states)
        true
      end

      private

      def render_diagram(graph, diagram, builder, draw_options)
        state_lookup = build_state_lookup(builder.machine)
        state_metadata = builder&.state_metadata || {}
        start_node = nil

        diagram.states.each do |state_node|
          metadata = state_metadata[state_node.id] || {}
          state = state_lookup[state_node.id]
          label = state ? state.description(human_name: draw_options[:human_name]) : (state_node.label || state_node.id)
          shape = metadata[:type] == 'final' ? 'doublecircle' : 'ellipse'

          node = graph.add_nodes(
            graph_node_id(state_node.id),
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

        transition_metadata = transition_metadata_map(builder)
        diagram.transitions.each do |transition|
          metadata = transition_metadata[transition] || {}
          callbacks = metadata[:callbacks] || {}

          graph.add_edges(
            graph_node_id(transition.source_state_id),
            graph_node_id(transition.target_state_id),
            label: transition.label.to_s,
            labelfontsize: 10,
            taillabel: Array(callbacks[:before]).compact.join("\n"),
            headlabel: Array(callbacks[:after]).compact.join("\n")
          )
        end
      end

      def build_state_lookup(machine)
        machine.states.each_with_object({}) do |state, memo|
          key = state.name ? state.name.to_s : 'nil_state'
          memo[key] = state
        end
      end

      def graph_node_id(diagram_state_id)
        diagram_state_id == 'nil_state' ? 'nil' : diagram_state_id
      end

      def transition_metadata_map(builder)
        Array(builder&.transition_metadata).each_with_object({}) do |metadata, memo|
          transition = metadata[:transition]
          memo[transition] = metadata if transition
        end
      end

      def draw_branch_with_label(branch, graph, event_label, machine, valid_states)
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
              label: event_label,
              labelfontsize: 10,
              taillabel: callback_method_names(machine, branch, :before).join("\n"),
              headlabel: callback_method_names(machine, branch, :after).join("\n")
            )
          end
        end
      end

      def callback_method_names(machine, branch, type)
        event_name = branch.event_requirement.values.first
        machine.callbacks[type].select do |callback|
          callback.branch.matches?(branch,
                                   from: branch.state_requirements.map { |req| req[:from] },
                                   to: branch.state_requirements.map { |req| req[:to] },
                                   on: event_name)
        end.flat_map do |callback|
          callback.instance_variable_get('@methods')
        end.compact
      end
    end
  end
end
