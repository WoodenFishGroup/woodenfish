# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "standalone_migrations"
StandaloneMigrations::Tasks.load_tasks
# comands
# rake db:new_migration name=foo_bar_migration
# rake db:migrate DB=dev/staging/prod
# rake db:rollback STEP=N DB=dev/staging/prod

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |task|
  #task.pattern = Dir['[0-9][0-9][0-9]_*/spec/*_spec.rb'].sort
  task.rspec_opts = Dir.glob("[0-9][0-9][0-9]_*").collect { |x| "-I#{x}"  }
end

task :default => :spec
