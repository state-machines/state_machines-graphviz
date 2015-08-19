require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, nil)

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('nil')
  end

  def test_should_have_a_node
    assert(@node)
  end

  def test_should_use_description_as_label
    assert_equal 'nil',@node['label'].to_s.gsub('"', '')
  end
end
