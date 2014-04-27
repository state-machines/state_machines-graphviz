context 'Drawing' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :value => 1)
    @machine.event :ignite do
      transition :parked => :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  it 'should_use_ellipse_shape' do
    expect(@node['shape'].to_s.gsub('"', '')).to eq('ellipse')
  end

  it 'should_set_width_to_one' do
    expect('1').to eq(@node['width'].to_s.gsub('"', ''))
  end

  it 'should_set_height_to_one' do
    expect('1').to eq(@node['height'].to_s.gsub('"', ''))
  end

  it 'should_use_description_as_label' do
    expect('parked (1)').to eq(@node['label'].to_s.gsub('"', ''))
  end
end

context 'DrawingInitial' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :initial => true)
    @machine.event :ignite do
      transition :parked => :idling
    end

    @graph = StateMachines::Graph.new('test')
    @state.draw(@graph)
    @node = @graph.get_node('parked')
  end

  it 'should_use_ellipse_as_shape' do
    expect('ellipse').to eq(@node['shape'].to_s.gsub('"', ''))
  end

  it 'should_draw_edge_between_point_and_state' do
    expect(2).to eq(@graph.node_count)
    expect(1).to eq(@graph.edge_count)
  end
end

context 'DrawingNilName' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, nil)

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('nil')
  end

  it 'should_have_a_node' do
    expect(@node).to be_truthy
  end

  it 'should_use_description_as_label' do
    expect('nil').to eq(@node['label'].to_s.gsub('"', ''))
  end
end

context 'DrawingLambdaValue' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :value => lambda {})

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  it 'should_have_a_node' do
    expect(@node).to be_truthy
  end

  it 'should_use_description_as_label' do
    expect('parked (*)').to eq(@node['label'].to_s.gsub('"', ''))
  end
end

context 'DrawingNonFinal' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked)
    @machine.event :ignite do
      transition :parked => :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  it 'should_use_ellipse_as_shape' do
    expect('ellipse').to eq(@node['shape'].to_s.gsub('"', ''))
  end
end

context 'DrawingFinal' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked)

    graph = StateMachines::Graph.new('test')
    @state.draw(graph)
    @node = graph.get_node('parked')
  end

  it 'should_use_doublecircle_as_shape' do
    expect('doublecircle').to eq(@node['shape'].to_s.gsub('"', ''))
  end
end

context 'DrawingWithHumanName' do
  before(:each) do
    @machine = StateMachines::Machine.new(Class.new)
    @machine.states << @state = StateMachines::State.new(@machine, :parked, :human_name => 'Parked')
    @machine.event :ignite do
      transition :parked => :idling
    end

    graph = StateMachines::Graph.new('test')
    @state.draw(graph, :human_name => true)
    @node = graph.get_node('parked')
  end

  it 'should_use_description_with_human_name_as_label' do
    expect('Parked').to eq(@node['label'].to_s.gsub('"', ''))
  end
end

