require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc "Run console with gem loaded"
task :console do
  require_relative 'lib/callback_hell'
  require 'irb'
  ARGV.clear
  IRB.start
end