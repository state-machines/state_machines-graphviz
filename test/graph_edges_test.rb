require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @graph = StateMachines::Graph.new('test')
    @graph.add_nodes('parked', :shape => 'ellipse')
    @graph.add_nodes('idling', :shape => 'ellipse')
    @edge = @graph.add_edges('parked', 'idling', :label => 'ignite')
  end

  def test_should_return_generated_edge
    refute_nil(@edge)
  end

  def test_should_use_specified_nodes
    assert_equal('parked' ,(@edge.node_one(false)))
    assert_equal('idling' ,(@edge.node_two(false)))
  end

  def test_should_use_specified_options
    assert_equal('ignite' ,@edge['label'].to_s.gsub('"', ''))
  end

  def test_should_set_default_font
    assert_equal(('Arial'),@edge['fontname'].to_s.gsub('"', ''))
  end
end
