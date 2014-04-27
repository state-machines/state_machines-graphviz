require 'spec_helper'
describe StateMachines::Graph do
  context 'GraphDefault' do
    before(:each) do
      @graph = StateMachines::Graph.new('test')
    end

    it 'should_have_a_default_font' do
      expect('Arial').to eq(@graph.font)
    end

    it 'should_use_current_directory_for_filepath' do
      expect('doc/state_machines/test.png').to eq(@graph.file_path)
    end

    it 'should_have_a_default_file_format' do
      expect('png').to eq(@graph.file_format)
    end

    it 'should_have_a_default_orientation' do
      expect('TB').to eq(@graph[:rankdir].source)
    end
  end

  context 'GraphNodes' do
    before(:each) do
      @graph = StateMachines::Graph.new('test')
      @node = @graph.add_nodes('parked', :shape => 'ellipse')
    end

    it 'should_return_generated_node' do
      expect(@node).to_not be_nil
    end

    it 'should_use_specified_name' do
      expect(@node).to eq(@graph.get_node('parked'))
    end

    it 'should_use_specified_options' do
      expect('ellipse').to eq(@node['shape'].to_s.gsub('"', ''))
    end

    it 'should_set_default_font' do
      expect('Arial').to eq(@node['fontname'].to_s.gsub('"', ''))
    end
  end

  context 'GraphEdges' do
    before(:each) do
      @graph = StateMachines::Graph.new('test')
      @graph.add_nodes('parked', :shape => 'ellipse')
      @graph.add_nodes('idling', :shape => 'ellipse')
      @edge = @graph.add_edges('parked', 'idling', :label => 'ignite')
    end

    it 'should_return_generated_edge' do
      expect(@edge).to_not be_nil
    end

    it 'should_use_specified_nodes' do
      expect('parked').to eq(@edge.node_one(false))
      expect('idling').to eq(@edge.node_two(false))
    end

    it 'should_use_specified_options' do
      expect('ignite').to eq(@edge['label'].to_s.gsub('"', ''))
    end

    it 'should_set_default_font' do
      expect('Arial').to eq(@edge['fontname'].to_s.gsub('"', ''))
    end
  end

  context 'GraphOutput' do
    before(:each) do
      @graph_name = "test_#{rand(1000000)}"
      @graph = StateMachines::Graph.new(@graph_name)
      @graph.add_nodes('parked', :shape => 'ellipse')
      @graph.add_nodes('idling', :shape => 'ellipse')
      @graph.add_edges('parked', 'idling', :label => 'ignite')
      @graph.output
    end

    it 'should_save_file' do
      expect(File.exist?("doc/state_machines/#{@graph_name}.png")).to be_truthy
    end

    after(:each) do
      FileUtils.rm Dir["doc/state_machines/#{@graph_name}.png"]
    end
  end
end
