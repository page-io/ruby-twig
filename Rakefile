require 'rake'
# require 'rake/testtask'
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "twig/version"

task default: [:rubocop, :rspec]

# desc 'run test suite with default parser'
# Rake::TestTask.new(:base_test) do |t|
#   t.libs << '.' << 'lib' << 'test'
#   t.test_files = FileList['test/{integration,unit}/**/*_test.rb']
#   t.verbose = false
# end

task :rubocop do
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

# desc 'runs test suite with both strict and lax parsers'
# task :test do
#   Rake::Task['base_test'].invoke
# end

task gem: :build
task :build do
  system "gem build ruby-twig.gemspec"
end

task install: :build do
  system "gem install ruby-twig-#{Twig::VERSION}.gem"
end

task release: :build do
  system "git tag -a v#{Twig::VERSION} -m 'Tagging #{Twig::VERSION}'"
  system "git push --tags"
  system "gem push ruby-twig-#{Twig::VERSION}.gem"
  system "rm ruby-twig-#{Twig::VERSION}.gem"
end

task :benchmark do
  desc "Run the twig benchmark"
  ruby "./performance/benchmark.rb"
end

namespace :profile do
  desc "Run the twig profile/performance coverage"
  task :run do
    ruby "./performance/profile.rb"
  end
end

desc "Run example"
task :example do
  ruby "-w -d -Ilib example/server/server.rb"
end

task :console do
  exec 'pry -r tilt -I lib -r twig -r pry'
end
