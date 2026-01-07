# frozen_string_literal: true

require 'bundler/setup'
require 'state_machines-graphviz'

root = File.expand_path('..', __dir__)
source = File.join(root, 'test', 'files', 'switch.rb')
output_path = File.join(root, 'doc')

StateMachines::Graphviz.draw(
  'Switch',
  file: source,
  path: output_path,
  format: 'svg',
  name: 'switch'
)
