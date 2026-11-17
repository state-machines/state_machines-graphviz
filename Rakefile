# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'shellwords'

Rake::TestTask.new(:minitest) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/*_test.rb'
end

# Both branches define :test, once per engine.
# rubocop:disable Rake/DuplicateTask
desc 'Run the test suite (padded_cell on CRuby, plain Minitest elsewhere)'
if RUBY_ENGINE == 'ruby'
  task :test do
    sh 'padded_cell', *Shellwords.split(ENV.fetch('TESTOPTS', ''))
  end
else
  task test: :minitest
end
# rubocop:enable Rake/DuplicateTask

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]
