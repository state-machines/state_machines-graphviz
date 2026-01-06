# frozen_string_literal: true

module StateMachines
  module Graphviz
    module Renderer
      extend self

      def draw_machine(machine, io: $stdout, **options)
        graph_options = options.dup
        name = graph_options.delete(:name) || "#{machine.owner_class.name}_#{machine.name}"

        draw_options = { human_name: false }
        if graph_options.key?(:human_names)
          draw_options[:human_name] = graph_options.delete(:human_names)
        elsif graph_options.key?(:human_name)
          draw_options[:human_name] = graph_options.delete(:human_name)
        end

        graph = Graph.new(name, graph_options)

        machine.states.by_priority.each { |state| state.draw(graph, draw_options) }
        machine.events.each { |event| draw_event(event, graph, draw_options, io) }

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
