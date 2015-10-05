require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/*_test.rb"
end


desc 'Default: run all tests.'
task :default => :test


load File.dirname(__FILE__) + '/lib/state_machines/tasks/state_machines.rake'