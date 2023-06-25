# frozen_string_literal: true

require 'state_machines/graphviz'
require 'rails'
module StateMachines
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'state_machines/tasks/state_machines.rake'
    end
  end
end
