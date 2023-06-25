require_relative 'lib/state_machines/graphviz/version'

Gem::Specification.new do |spec|
  spec.name          = 'state_machines-graphviz'
  spec.version       = StateMachines::Graphviz::VERSION
  spec.authors       = ['Abdelkader Boudih', 'Aaron Pfeifer']
  spec.email         = ['terminale@gmail.com']
  spec.summary       = %q(Drawing module for state machines)
  spec.description   = %q(Graphviz module for state machines)
  spec.homepage      = 'https://github.com/state-machines/state_machines-graphviz'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib}/**/*', 'LICENSE.txt', 'README.md']
  spec.test_files    = Dir['test/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'state_machines'
  spec.add_dependency 'ruby-graphviz'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '>=5.6.0'
end
