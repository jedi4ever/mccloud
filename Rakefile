require 'bundler/setup'
Bundler::GemHelper.install_tasks

#desc 'Default: run tests'
#task :default => :test

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
