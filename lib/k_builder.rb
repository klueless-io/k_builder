# frozen_string_literal: true

require 'k_builder/version'
require 'k_builder/logging'
require 'k_builder/base_builder'
require 'k_builder/base_configuration'
require 'k_builder/configuration'
require 'k_builder/file_segments'
require 'k_builder/named_folders'
require 'k_builder/layered_folders'
require 'k_util'

require 'handlebars/helpers/template'

module KBuilder
  # raise KBuilder::Error, 'Sample message'
  class Error < StandardError; end
end

puts "KBuilder::Version: #{KBuilder::VERSION}" if ENV['KLUE_DEBUG']&.to_s&.downcase == 'true'
