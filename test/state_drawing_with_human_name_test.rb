require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :human_name => 'Parked')
    @machine.event :ignite do
      transition :parked => :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph, :human_name => true)
    @node = graph.get_node('parked')
  end

  def test_should_use_description_with_human_name_as_label
    assert_equal('Parked',@node['label'].to_s.gsub('"', ''))
  end
end
