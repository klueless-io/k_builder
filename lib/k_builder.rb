# frozen_string_literal: true

require 'k_builder/version'
require 'k_builder/base_builder'
require 'k_builder/base_configuration'
require 'k_builder/configuration'
require 'k_builder/file_segments'
require 'k_builder/named_folders'
require 'k_builder/layered_folders'
require 'k_log'
require 'k_util'

require 'handlebars/helpers/template'

module KBuilder
  # raise KBuilder::Error, 'Sample message'
  class Error < StandardError; end

  # Need to move this into a KLog factory
  def self.configure_logger
    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG
    logger.formatter = KLog::LogFormatter.new
    KLog::LogUtil.new(logger)
  end
end

L = KBuilder.configure_logger
