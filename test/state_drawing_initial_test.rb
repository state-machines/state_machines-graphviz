# frozen_string_literal: true

require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, initial: true)
    @machine.event :ignite do
      transition parked: :idling
    end

    @graph = StateMachines::Graph.new('test')
    @state.draw(@graph)
    @node = @graph.get_node('parked')
  end

  def test_should_use_ellipse_as_shape
    assert_equal 'ellipse', @node['shape'].to_s.gsub('"', '')
  end

  def test_should_draw_edge_between_point_and_state
    assert_equal(2, @graph.node_count)
    assert_equal(1, @graph.edge_count)
  end
end
