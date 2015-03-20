require 'state_machines/graphviz'
require 'rails'
module StateMachines
  # https://gist.github.com/josevalim/af7e572c2dc973add221
  class Railtie < Rails::Railtie
    rake_tasks do
      load 'state_machines/tasks/state_machines.rake'
    end
  end
end