require 'rake'

desc "Run tests hypothetically"
task :default => :test

#Rake::TestTask.new do |t|
# t.libs << 'test'
#end

namespace :test do
  desc "Run mini tests"
  task :mini => :clean do
    Dir['test/test_mini*'].each do |file|
      system "ruby #{file}"
    end
  end
end

#begin
#  require 'rspec/core/rake_task'             
#rescue LoadError
#  require 'rubygems'
#  retry
#end

#RSpec::Core::RakeTask.new(:spec) do |t|
#  t.pattern = 'spec/*_spec.rb'
#end

#task :test => [:spec]

#task :default => :test

#return 0
