describe StateMachines::Machine do
  before(:each) do
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

  it 'should not raise exception' do
    expect { @machine.draw }.not_to raise_error
  end

end
