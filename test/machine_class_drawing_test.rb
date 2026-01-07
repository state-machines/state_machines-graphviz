# frozen_string_literal: true

require_relative 'test_helper'

describe StateMachines::Machine do
  def switch_file
    File.expand_path("#{File.dirname(__FILE__)}/files/switch.rb")
  end

  def switch_machine
    require switch_file
    Switch.state_machines.values.first
  end

  def test_should_load_files
    machine = switch_machine
    assert(defined?(::Switch))
    assert(machine)
  end

  def test_should_allow_path_and_format_to_be_customized
    machine = switch_machine
    output_path = File.dirname(__FILE__)
    machine.draw(path: output_path, format: 'jpg')
    assert(File.exist?("#{output_path}/#{Switch.name}_state.jpg"))
    FileUtils.rm Dir["{.,#{output_path}}/#{Switch.name}_state.{jpg,png}"]
  end
end
