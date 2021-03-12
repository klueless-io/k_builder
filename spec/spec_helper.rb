# frozen_string_literal: true

require 'pry'
require 'bundler/setup'
require 'k_builder'

# TODO: Improvements needed
# Move [Gem.loaded_specs['handlebars-helpers'].full_gem_path] into a method inside handlebars helpers
#      https://github.com/rubygems/rubygems/blob/master/lib/rubygems.rb#L1197
# Allow more then one configuration file
Handlebars::Helpers.configure do |config|
  config_file = File.join(Gem.loaded_specs['handlebars-helpers'].full_gem_path, '.handlebars_helpers.json')
  config.helper_config_file = config_file
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'
  config.filter_run_when_matching :focus

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
