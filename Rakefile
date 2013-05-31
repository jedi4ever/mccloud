require 'bundler/setup'
Bundler::GemHelper.install_tasks

desc 'Default: run tests'
task :default => :test

require 'rake'
require 'rspec/core/rake_task'
require 'rake/testtask'


desc 'Tests not requiring an real box'
Rake::TestTask.new do |t|
   t.libs << "test"
   t.pattern = 'test/**/*_test.rb'
end

desc 'Tests requiring an real providers'
  Rake::TestTask.new do |t|
  t.name="realtest"
  t.libs << "test"
  t.pattern = 'test/**/*_realtest.rb'
end


desc 'Specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = './spec/**/*_spec.rb' # don't need this, it's default
  t.verbose = true
  #t.rspec_opts = "--format documentation --color"
  # Put spec opts in a file named .rspec in root
end
