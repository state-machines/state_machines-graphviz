# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'state_machines/graphviz/version'

Gem::Specification.new do |spec|
  spec.name          = 'state_machines-graphviz'
  spec.version       = StateMachines::Graphviz::VERSION
  spec.authors       = ['Abdelkader Boudih', 'Aaron Pfeifer']
  spec.email         = ['terminale@gmail.com']
  spec.summary       = %q(Drawing module for state machines)
  spec.description   = %q(Graphviz module for state machines)
  spec.homepage      = 'https://github.com/seuros/state_machines-graphviz'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{/^spec\//})
  spec.require_paths = ['lib']

  spec.add_dependency 'state_machines'
  spec.add_dependency 'ruby-graphviz'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec' , '3.0.0.beta2'
end
