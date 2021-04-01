# frozen_string_literal: true

GEM_NAME = 'k_builder'

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'k_builder/version'

RSpec::Core::RakeTask.new(:spec)

require 'rake/extensiontask'

desc 'Compile all the extensions'
task build: :compile

Rake::ExtensionTask.new('k_builder') do |ext|
  ext.lib_dir = 'lib/k_builder'
end

desc 'Publish the gem to RubyGems.org'
task :publish do
  system 'gem build'
  system "gem push #{GEM_NAME}-#{KBuilder::VERSION}.gem"
end

desc 'Remove old *.gem files'
task :clean do
  system 'rm *.gem'
end

task default: %i[clobber compile spec]
