# frozen_string_literal: true

require_relative 'lib/state_machines/graphviz/version'

Gem::Specification.new do |spec|
  spec.name          = 'state_machines-graphviz'
  spec.version       = StateMachines::Graphviz::VERSION
  spec.authors       = ['Abdelkader Boudih', 'Aaron Pfeifer']
  spec.email         = ['terminale@gmail.com']
  spec.summary       = 'Drawing module for state machines'
  spec.description   = 'Graphviz module for state machines'
  spec.homepage      = 'https://github.com/state-machines/state_machines-graphviz'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 4.0'

  spec.files         = Dir['{lib}/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'ruby-graphviz'
  spec.add_dependency 'state_machines', '>= 0.304.0'
  spec.add_dependency 'state_machines-diagram', '>= 0.4.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 6.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop', '~> 1.59'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.34'
  spec.add_development_dependency 'rubocop-performance', '~> 1.20'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
