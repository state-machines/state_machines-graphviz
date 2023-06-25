# frozen_string_literal: true

require 'state_machines'
require 'graphviz'
require 'state_machines/graphviz/monkeypatch'
require 'state_machines/graphviz/graph'
require 'state_machines/graphviz/version'

require 'state_machines/tasks/railtie' if defined?(Rails)
