# frozen_string_literal: true

require 'state_machines/graphviz'

# Loading the gem changes no global state. Machine#draw (and State, Event
# and Branch#draw) use this renderer once it is chosen:
#
#   StateMachines::Machine.renderer = StateMachines::Graphviz::Renderer
#
# or draw with it directly: StateMachines::Graphviz::Renderer.draw_machine(machine),
# StateMachines::Graphviz.draw('Vehicle'), or the state_machines:draw task.
