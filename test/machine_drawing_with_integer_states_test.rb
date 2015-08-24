require_relative 'test_helper'

describe StateMachines::Graph do
  def setup
    @klass = Class.new do
      def self.name
        @name ||= "Vehicle_#{rand(1_000_000)}"
      end
    end

    @machine = StateMachines::Machine.new(@klass, :state_id, initial: :parked)
    @machine.event :ignite do
      transition parked: :idling
    end
    @machine.state :parked, value: 1
    @machine.state :idling, value: 2

    @graph = @machine.draw

  end

  def test_should_draw_all_states
    assert_equal(@graph.node_count,3)
  end

  def test_should_draw_all_events
    assert_equal(@graph.edge_count,2)
  end

  def test_should_draw_machine
    assert(File.exist?("doc/state_machines/#{@klass.name}_state_id.png"))
  end

  def teardown
    assert(File.exist?("doc/state_machines/#{@klass.name}_state_id.png"))
  end
end