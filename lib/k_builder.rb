# frozen_string_literal: true

require 'rubocop'

require 'k_log'
require 'k_util'
require 'k_type'
require 'k_builder/version'
require 'k_builder/base_builder'
require 'k_builder/base_configuration'
require 'k_builder/configuration'
require 'k_builder/file_segments'
require 'k_builder/commands/base_command'
require 'k_builder/commands/rubo_cop_command'

require 'handlebars/helpers/template'

module KBuilder
  # raise KBuilder::Error, 'Sample message'
  class Error < StandardError; end
end

if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
  namespace = 'KBuilder::Version'
  file_path = $LOADED_FEATURES.find { |f| f.include?('k_builder/version') }
  version   = KBuilder::VERSION.ljust(9)
  puts "#{namespace.ljust(35)} : #{version.ljust(9)} : #{file_path}"
end
