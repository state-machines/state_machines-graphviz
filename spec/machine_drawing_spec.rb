describe StateMachines::Graphviz do
  context 'Drawing' do
    let(:klass) do
      Class.new do
        def self.name
          @name ||= "Vehicle_#{rand(1_000_000)}"
        end
      end
    end
    let(:machine) { StateMachines::Machine.new(klass, initial: :parked) }

    before(:each) do
      machine.event :ignite do
        transition parked: :idling
      end
    end

    it 'should_raise_exception_if_invalid_option_specified' do
      expect { machine.draw(invalid: true) }.to raise_error(ArgumentError)
    end

    it 'should_save_file_with_class_name_by_default' do
      machine.draw
      expect(File.exist?("doc/state_machines/#{klass.name}_state.png")).to be_truthy
    end

    it 'should_allow_base_name_to_be_customized' do
      name = "machine_#{rand(1_000_000)}"
      machine.draw(name: name)
      @path = "doc/state_machines/#{name}.png"
      expect(File.exist?(@path)).to be_truthy
    end

    it 'should_allow_format_to_be_customized' do
      machine.draw(format: 'jpg')
      @path = "doc/state_machines/#{klass.name}_state.jpg"
      expect(File.exist?(@path)).to be_truthy
    end

    it 'should_allow_path_to_be_customized' do
      machine.draw(path: "#{File.dirname(__FILE__)}/")
      @path = "#{File.dirname(__FILE__)}/#{klass.name}_state.png"
      expect(File.exist?(@path)).to be_truthy
    end

    it 'should_allow_orientation_to_be_landscape' do
      graph = machine.draw(orientation: 'landscape')
      expect(graph['rankdir'].to_s.gsub('"', '')).to eq('LR')
    end

    it 'should_allow_orientation_to_be_portrait' do
      graph = machine.draw(orientation: 'portrait')
      expect(graph['rankdir'].to_s.gsub('"', '')).to eq('TB')
    end

    it 'should_allow_human_names_to_be_displayed' do
      machine.event :ignite, human_name: 'Ignite'
      machine.state :parked, human_name: 'Parked'
      machine.state :idling, human_name: 'Idling'
      graph = machine.draw(human_names: true)

      parked_node = graph.get_node('parked')
      expect(parked_node['label'].to_s.gsub('"', '')).to eq('Parked')

      idling_node = graph.get_node('idling')
      expect(idling_node['label'].to_s.gsub('"', '')).to eq('Idling')
    end

    after(:each) do
      FileUtils.rm Dir[@path || "doc/state_machines/#{klass.name}_state.png"]
    end
  end

  context 'DrawingWithIntegerStates' do
    let(:klass) do
      Class.new do
        def self.name
          @name ||= "Vehicle_#{rand(1_000_000)}"
        end
      end
    end

    let(:machine) { StateMachines::Machine.new(klass, :state_id, initial: :parked) }
    before(:each) do
      machine.event :ignite do
        transition parked: :idling
      end
      machine.state :parked, value: 1
      machine.state :idling, value: 2
    end

    let!(:graph) { machine.draw }

    it 'should_draw_all_states' do
      expect(graph.node_count).to eq(3)
    end

    it 'should_draw_all_events' do
      expect(graph.edge_count).to eq(2)
    end

    it 'should_draw_machine' do
      expect(File.exist?("doc/state_machines/#{klass.name}_state_id.png")).to be_truthy
    end

    after(:each) do
      FileUtils.rm Dir["doc/state_machines/#{klass.name}_state_id.png"]
    end
  end

  context 'DrawingWithNilStates' do
    let(:klass) do
      Class.new do
        def self.name
          @name ||= "Vehicle_#{rand(1_000_000)}"
        end
      end
    end
    let(:machine) { StateMachines::Machine.new(klass, initial: :parked) }

    before(:each) do
      machine.event :ignite do
        transition parked: :idling
      end
      machine.state :parked, value: nil
    end

    let!(:graph) { machine.draw }

    it 'should_draw_all_states' do
      expect(graph.node_count).to eq(3)
    end

    it 'should_draw_all_events' do
      expect(graph.edge_count).to eq(2)
    end

    it 'should_draw_machine' do
      expect(File.exist?("doc/state_machines/#{klass.name}_state.png")).to be_truthy
    end

    after(:each) do
      FileUtils.rm Dir["doc/state_machines/#{klass.name}_state.png"]
    end
  end

  context 'DrawingWithDynamicStates' do
    let(:klass) do
      Class.new do
        def self.name
          @name ||= "Vehicle_#{rand(1_000_000)}"
        end
      end
    end

    let(:machine) { StateMachines::Machine.new(klass, initial: :parked) }

    before(:each) do
      machine.event :activate do
        transition parked: :idling
      end
      machine.state :idling, value: lambda { Time.now }
    end

    let!(:graph) { machine.draw }

    it 'should_draw_all_states' do
      expect(graph.node_count).to eq(3)
    end

    it 'should_draw_all_events' do
      expect(graph.edge_count).to eq(2)
    end

    it 'should_draw_machine' do
      expect(File.exist?("doc/state_machines/#{klass.name}_state.png")).to be_truthy
    end

    after(:each) do
      FileUtils.rm Dir["doc/state_machines/#{klass.name}_state.png"]
    end

  end

  context 'ClassDrawing' do
    before(:each) do
      klass = Class.new do
        def self.name
          @name ||= "Vehicle_#{rand(1_000_000)}"
        end
      end
      machine = StateMachines::Machine.new(klass)
      machine.event :ignite do
        transition parked: :idling
      end
    end

    it 'should_raise_exception_if_no_class_names_specified' do
      expect { StateMachines::Machine.draw(nil) }.to raise_error(ArgumentError)
      # FixMe
      # assert_equal 'At least one class must be specified', exception.message
    end

    it 'should_load_files' do
      StateMachines::Machine.draw('Switch', file: File.expand_path("#{File.dirname(__FILE__)}/files/switch.rb"))
      expect(defined?(::Switch)).to be_truthy
    end

    it 'should_allow_path_and_format_to_be_customized' do
      StateMachines::Machine.draw('Switch', file: File.expand_path("#{File.dirname(__FILE__)}/files/switch.rb"), path: "#{File.dirname(__FILE__)}/", format: 'jpg')
      expect(File.exist?("#{File.dirname(__FILE__)}/#{Switch.name}_state.jpg")).to be_truthy
      FileUtils.rm Dir["{.,#{File.dirname(__FILE__)}}/#{Switch.name}_state.{jpg,png}"]
    end
  end
end
