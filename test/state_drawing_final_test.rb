# frozen_string_literal: true

require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked)

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  def test_should_use_doublecircle_as_shape
    assert_equal('doublecircle', @node['shape'].to_s.gsub('"', ''))
  end
end
