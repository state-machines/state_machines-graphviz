require_relative 'test_helper'
describe StateMachines::Machine do
  def setup
    klass =  Class.new do
      def self.name
        @name ||= "Vehicle_#{rand(1_000_000)}"
      end
    end

    @machine = StateMachines::Machine.new(klass, initial: :parked)
    @machine.event :ignite do
      transition parked: :idling
    end
  end

end