require_relative 'test_helper'

describe StateMachines::Graph do
  def setup
    @klass = Class.new do
      def self.name
        @name ||= "Vehicle_#{rand(1_000_000)}"
      end
    end

    @machine = StateMachines::Machine.new(@klass, initial: :parked)
    @machine.event :activate do
      transition parked: :idling
    end

    @machine.state :idling, value: lambda { Time.now }

    @graph = @machine.draw

  end
  
  def test_should_draw_all_states
    assert(@graph.node_count,3)
  end

  def test_should_draw_all_events
    assert(@graph.edge_count,2)
  end

  def test_should_draw_machine
    assert(File.exist?("doc/state_machines/#{@klass.name}_state.png"))
  end

  def teardown
    FileUtils.rm Dir["doc/state_machines/#{@klass.name}_state.png"]
  end
end