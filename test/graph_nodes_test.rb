require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @graph = StateMachines::Graph.new('test')
    @node = @graph.add_nodes('parked', :shape => 'ellipse')
  end

  def test_should_return_generated_node
    refute_nil @node
  end

  def test_should_use_specified_name
    assert_equal(@node,@graph.get_node('parked'))
  end

  def test_should_use_specified_options
    assert_equal('ellipse',@node['shape'].to_s.gsub('"', ''))
  end

  def test_should_set_default_font
    assert_equal('Arial',@node['fontname'].to_s.gsub('"', ''))
  end
end

