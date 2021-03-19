# frozen_string_literal: true

require 'k_builder/version'
require 'k_builder/base_builder'
require 'k_builder/base_configuration'
require 'k_builder/builder'
require 'k_builder/configuration'
require 'k_builder/data_helper'
require 'k_builder/named_folders'
require 'k_builder/layered_folders'

require 'handlebars/helpers/template'

module KBuilder
  # raise KBuilder::Error, 'Sample message'
  class Error < StandardError; end

  # Your code goes here...
end
