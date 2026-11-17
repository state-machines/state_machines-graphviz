# frozen_string_literal: true

require_relative 'test_helper'

describe StateMachines::Graph do
  def setup
    @klass = Class.new do
      def self.name
        @name ||= "Vehicle_#{SecureRandom.hex(6)}"
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
    assert_equal(3, @graph.node_count)
  end

  def test_should_draw_all_events
    assert_equal(2, @graph.edge_count)
  end

  def test_should_draw_machine
    assert_path_exists("doc/state_machines/#{@klass.name}_state_id.png")
  end

  def teardown
    FileUtils.rm_f("doc/state_machines/#{@klass.name}_state_id.png")
  end
end
