require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :value => 1)
    @machine.event :ignite do
      transition :parked => :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end


  def test_should_use_ellipse_shape
    assert_equal(@node['shape'].to_s.gsub('"', '') ,'ellipse')
  end

  def test_should_set_width_to_one
    assert_equal('1',@node['width'].to_s.gsub('"', ''))
  end

  def test_should_set_height_to_one
    assert_equal('1',@node['height'].to_s.gsub('"', '') )
  end

  def test_should_use_description_as_label
    assert_equal(@node['label'].to_s.gsub('"', '') ,'parked (1)')
  end
end
