require_relative 'test_helper'

describe StateMachines::Graph do
  def setup
    @klass = Class.new do
      def self.name
        @name ||= "Vehicle_#{rand(1_000_000)}"
      end
    end

    @machine = StateMachines::Machine.new(@klass)
    @machine.event :ignite do
      transition parked: :idling
    end

  end

  def test_should_raise_exception_if_no_class_names_specified
    assert_raises(ArgumentError) {StateMachines::Machine.draw(nil)}
  end

  def test_should_load_files
    StateMachines::Machine.draw('Switch', file: File.expand_path("#{File.dirname(__FILE__)}/files/switch.rb"))
    assert(defined?(::Switch))
  end

  def test_should_allow_path_and_format_to_be_customized
    StateMachines::Machine.draw('Switch', file: File.expand_path("#{File.dirname(__FILE__)}/files/switch.rb"), path: "#{File.dirname(__FILE__)}/", format: 'jpg')
    assert(File.exist?("#{File.dirname(__FILE__)}/#{Switch.name}_state.jpg"))
    FileUtils.rm Dir["{.,#{File.dirname(__FILE__)}}/#{Switch.name}_state.{jpg,png}"]
  end

end
