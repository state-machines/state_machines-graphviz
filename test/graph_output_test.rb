# frozen_string_literal: true

require_relative 'test_helper'
describe StateMachines::Graph do
  def setup
    @graph_name = "test_#{rand(1_000_000)}"
    @graph = StateMachines::Graph.new(@graph_name)
    @graph.add_nodes('parked', shape: 'ellipse')
    @graph.add_nodes('idling', shape: 'ellipse')
    @graph.add_edges('parked', 'idling', label: 'ignite')
    @graph.output
  end

  def test_should_save_file
    assert File.exist?("doc/state_machines/#{@graph_name}.png")
  end

  def teardown
    FileUtils.rm Dir["doc/state_machines/#{@graph_name}.png"]
  end
end
