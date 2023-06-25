# frozen_string_literal: true

require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked)
    @machine.event :ignite do
      transition parked: :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  def test_should_use_ellipse_as_shape
    assert_equal('ellipse', @node['shape'].to_s.gsub('"', ''))
  end
end
