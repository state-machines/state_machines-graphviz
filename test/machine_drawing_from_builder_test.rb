# frozen_string_literal: true

require_relative 'test_helper'
require 'tmpdir'

# What a drawn machine shows comes from StateMachines::Diagram::Builder: the
# markers, the transitions the core performs, their guards and callbacks.
class MachineDrawingFromBuilderTest < Minitest::Test
  def setup
    @dir = Dir.mktmpdir('state_machines-graphviz')
    @klass = Class.new do
      def self.name = 'Vehicle'
    end
  end

  def teardown
    FileUtils.rm_rf(@dir)
  end

  def machine(name = :state, **, &)
    StateMachines::Machine.new(@klass, name, **, &)
  end

  def draw(machine, **)
    StateMachines::Graphviz::Renderer.draw_machine(machine, path: @dir, format: 'dot', **)
  end

  # An attribute as DOT writes it
  def dot(element, attribute)
    element[attribute].to_s
  end

  def edges(graph)
    edges = []
    graph.each_edge { edges << it }
    edges.to_h { [[it.node_one(false, false), it.node_two(false, false)], it] }
  end

  def test_initial_state_has_a_start_point_and_final_state_a_double_circle
    graph = draw(machine(initial: :parked) { event(:ignite) { transition parked: :idling } })

    start = graph.get_node(StateMachines::Graphviz::Renderer::START_NODE_ID)

    assert_equal('"point"', dot(start, 'shape'))
    assert_includes(edges(graph).keys, %w[* parked])
    assert_equal('"ellipse"', dot(graph.get_node('parked'), 'shape'))
    assert_equal('"doublecircle"', dot(graph.get_node('idling'), 'shape'))
  end

  def test_a_state_both_initial_and_final_gets_both_markers
    graph = draw(machine(initial: :parked) { state :parked })

    assert_equal('"doublecircle"', dot(graph.get_node('parked'), 'shape'))
    assert_includes(edges(graph).keys, %w[* parked])
  end

  def test_guards_read_as_the_core_runs_them
    graph = draw(machine(initial: :parked) do
      event :drive do
        transition parked: :moving, if: [:engine_started?, 'fuel > 0'], unless: :braking?,
                   if_state: { gate: :unlocked }
      end
    end)

    label = dot(edges(graph).fetch(%w[parked moving]), 'label')

    assert_equal('"drive\n[if engine_started? && if (fuel > 0) && unless braking? && if_state gate=unlocked]"', label)
  end

  def test_a_state_guard_keeps_its_requirements_together_under_its_kind
    graph = draw(machine(initial: :parked) do
      event :drive do
        transition parked: :moving, if_any_state: { gate: :open, alarm: nil },
                   unless_all_states: { gate: :closed, alarm: :on }
      end
    end)

    label = dot(edges(graph).fetch(%w[parked moving]), 'label')

    # The core checks state guards in its own order, whatever order they are written in
    assert_equal('"drive\n[unless_all_states (gate=closed, alarm=on) && if_any_state (gate=open, alarm=nil)]"', label)
  end

  def test_an_unguarded_branch_settles_its_source
    graph = draw(machine(initial: :parked) do
      event :go do
        transition parked: :idling, if: :warm?
        transition parked: :moving
        transition parked: :stalled
      end
    end)

    assert_equal([%w[* parked], %w[parked idling], %w[parked moving]], edges(graph).keys)
  end

  def test_callbacks_show_on_the_transitions_they_run_on
    graph = draw(machine(initial: :parked) do
      before_transition from: :parked, do: :check_mirrors
      around_transition on: :ignite, do: :hold_brake
      after_transition to: :idling, do: :log_start, if: :logging?
      after_transition from: :idling, do: :log_stop
      event(:ignite) { transition parked: :idling }
      event(:park) { transition idling: :parked }
    end)

    ignite = edges(graph).fetch(%w[parked idling])
    park = edges(graph).fetch(%w[idling parked])

    assert_equal('"check_mirrors\nhold_brake"', dot(ignite, 'taillabel'))
    assert_equal('"log_start (if logging?)"', dot(ignite, 'headlabel'))
    assert_equal('""', dot(park, 'taillabel'))
    assert_equal('"log_stop"', dot(park, 'headlabel'))
  end

  def test_human_names_label_states_and_events
    graph = draw(machine(initial: :parked) do
      state :parked, human_name: 'Parked'
      event(:ignite, human_name: 'Ignite') { transition parked: :idling }
    end, human_names: true)

    assert_equal('"Parked"', dot(graph.get_node('parked'), 'label'))
    assert_equal('"Ignite"', dot(edges(graph).fetch(%w[parked idling]), 'label'))
  end

  def test_the_nil_state_and_a_state_named_nil_are_distinct_nodes
    graph = draw(machine(initial: :parked) do
      event(:reset) { transition parked: nil }
      event(:named) { transition parked: :nil }
    end)

    assert_equal('"nil"', dot(graph.get_node('nil_state'), 'label'))
    assert_equal('"nil"', dot(graph.get_node('nil'), 'label'))
    assert_equal([%w[* parked], %w[parked nil_state], %w[parked nil]], edges(graph).keys)
  end

  def test_names_dot_would_misread_are_drawn_as_written
    graph = draw(machine(initial: :'a\\N') do
      state :'<b>x</b>'
      event(:go) { transition 'a\\N': :'<b>x</b>' }
    end)
    source = File.read(File.join(@dir, 'Vehicle_state.dot'))
    alias_id = StateMachines::Graphviz::Renderer.node_id('a\N')

    assert_equal('%615c4e', alias_id)
    assert_equal('"a\\\\N"', dot(graph.get_node(alias_id), 'label'))
    assert_equal('"\\<b>x\\</b>"', dot(graph.get_node('<b>x</b>'), 'label'))
    refute_match(/label = </, source)
  end

  def test_a_state_named_like_the_start_point_is_not_the_start_point
    graph = draw(machine(initial: :parked) { event(:go) { transition parked: :* } })

    assert_equal('"point"', dot(graph.get_node('*'), 'shape'))
    assert_equal('"*"', dot(graph.get_node(StateMachines::Diagram::Builder.state_id(:*)), 'label'))
  end

  def test_an_event_draws_its_transitions_and_their_states
    machine = machine(initial: :parked) do
      event(:ignite) { transition parked: :idling }
      event(:park) { transition idling: :parked }
    end
    graph = StateMachines::Graph.new('event', path: @dir)

    machine.events[:ignite].draw(graph)

    assert_equal([%w[* parked], %w[parked idling]], edges(graph).keys)
    assert_equal('"ignite"', dot(edges(graph).fetch(%w[parked idling]), 'label'))
  end

  def test_a_branch_draws_only_its_own_transitions
    machine = machine(initial: :parked) do
      event :go do
        transition parked: :idling, if: :warm?
        transition parked: :moving
      end
    end
    event = machine.events[:go]
    graph = StateMachines::Graph.new('branch', path: @dir)

    event.branches.last.draw(graph, event, [])

    assert_equal([%w[* parked], %w[parked moving]], edges(graph).keys)
  end
end
