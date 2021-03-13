# frozen_string_literal: true

# Attach configuration to the KBuilder module
module KBuilder
  # Configuration for webpack5/builder
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  # Configuration class
  class Configuration < BaseConfiguration
    attr_accessor :target_folder
    attr_accessor :template_folder
    attr_accessor :global_template_folder

    def initialize
      super
      @target_folder = Dir.getwd
      @template_folder = File.join(Dir.getwd, '.templates')
      @global_template_folder = nil
    end

    def debug
      puts '-' * 120
      puts 'kbuilder base configuration'
      kv 'target_folder'         , target_folder
      kv 'template_folder'       , template_folder
      kv 'global_template_folder', global_template_folder
    end
  end
end
