# frozen_string_literal: true

require_relative 'test_helper'

describe StateMachines::Graph do
  def setup
    @klass = Class.new do
      def self.name
        @name ||= "Vehicle_#{rand(1_000_000)}"
      end
    end

    @machine = StateMachines::Machine.new(@klass, initial: :parked)
    @machine.event :ignite do
      transition parked: :idling
    end
  end

  def test_should_raise_exception_if_invalid_option_specified
    assert_raises(ArgumentError) { @machine.draw(invalid: true) }
  end

  def test_should_save_file_with_class_name_by_default
    @machine.draw
    assert File.exist?("doc/state_machines/#{@klass.name}_state.png"), 'Failed to save file with class name'
  end

  def test_should_allow_base_name_to_be_customized
    name = "@machine_#{rand(1_000_000)}"
    @machine.draw(name: name)
    @path = "doc/state_@machines/#{name}.png"
  end

  def test_should_allow_format_to_be_customized
    @machine.draw(format: 'jpg')
    @path = "doc/state_machines/#{@klass.name}_state.jpg"
    assert File.exist?(@path), 'allow format to be custom'
  end

  def test_should_allow_path_to_be_customized
    @machine.draw(path: "#{File.dirname(__FILE__)}/")
    @path = "#{File.dirname(__FILE__)}/#{@klass.name}_state.png"
    assert(File.exist?(@path))
  end

  def test_should_allow_orientation_to_be_landscape
    @graph = @machine.draw(orientation: 'landscape')
    assert_equal(@graph['rankdir'].to_s.gsub('"', ''), 'LR')
  end

  def test_should_allow_orientation_to_be_portrait
    @graph = @machine.draw(orientation: 'portrait')
    assert_equal(@graph['rankdir'].to_s.gsub('"', ''), 'TB')
  end

  def test_should_allow_human_names_to_be_displayed
    @machine.event :ignite, human_name: 'Ignite'
    @machine.state :parked, human_name: 'Parked'
    @machine.state :idling, human_name: 'Idling'
    @graph = @machine.draw(human_names: true)

    parked_node = @graph.get_node('parked')
    assert_equal(parked_node['label'].to_s.gsub('"', ''), 'Parked')

    idling_node = @graph.get_node('idling')
    assert_equal(idling_node['label'].to_s.gsub('"', ''), 'Idling')
  end

  def teardown
    FileUtils.rm Dir[@path || "doc/state_@machines/#{@klass.name}_state.png"]
  end
end
