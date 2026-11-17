# frozen_string_literal: true

require 'state_machines'
require 'graphviz'
require 'state_machines/graphviz/graph'
require 'state_machines/graphviz/renderer'
require 'state_machines/graphviz/version'

module StateMachines
  module Graphviz
    module_function

    # Draws every state machine of each class in +class_names+ (a
    # comma-separated list) with GraphViz, whichever renderer machines use
    def draw(class_names, options = {})
      names = class_names.to_s.split(',').map(&:strip).reject(&:empty?)
      raise ArgumentError, 'At least one class must be specified' if names.empty?

      options = options.dup
      options.delete(:file).to_s.split(',').each { |file| require file.strip }

      names.each do |class_name|
        Object.const_get(class_name).state_machines.each_value do |machine|
          Renderer.draw_machine(machine, **options)
        end
      end
    end
  end
end

require 'state_machines/tasks/railtie' if defined?(Rails)
