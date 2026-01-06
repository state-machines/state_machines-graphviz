# frozen_string_literal: true

require 'state_machines'
require 'graphviz'
require 'state_machines/graphviz/graph'
require 'state_machines/graphviz/renderer'
require 'state_machines/graphviz/version'

module StateMachines
  module Graphviz
    module_function

    def draw(class_names, options = {})
      if class_names.nil? || class_names.to_s.split(',').empty?
        raise ArgumentError, 'At least one class must be specified'
      end

      # Load any files
      if (files = options.delete(:file))
        files.split(',').each { |file| require file }
      end

      class_names.to_s.split(',').each do |class_name|
        # Navigate through the namespace structure to get to the class
        klass = Object
        class_name.split('::').each do |name|
          klass = klass.const_defined?(name) ? klass.const_get(name) : klass.const_missing(name)
        end

        # Draw each of the class's state machines
        klass.state_machines.each_value do |machine|
          machine.draw(**options)
        end
      end
    end
  end
end

require 'state_machines/tasks/railtie' if defined?(Rails)
