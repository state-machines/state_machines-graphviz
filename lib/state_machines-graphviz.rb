# frozen_string_literal: true

require 'state_machines/graphviz'

# Set the renderer to use graphviz
StateMachines::Machine.renderer = StateMachines::Graphviz::Renderer
