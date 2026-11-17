# frozen_string_literal: true

require 'state_machines-graphviz'
require 'minitest/autorun'
require 'minitest/pride'
require 'securerandom'

# Machine#draw, State#draw, Event#draw and Branch#draw go through the chosen
# renderer; the gem chooses none on require
StateMachines::Machine.renderer = StateMachines::Graphviz::Renderer
