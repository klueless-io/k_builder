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
  class Configuration
    attr_accessor :target_folder_base
    attr_accessor :global_template_folder

    def initialize
      @target_folder_base = Dir.getwd
      @global_template_folder = File.join(Dir.getwd, '.templates')
    end

    def debug
      puts '-' * 120
      puts 'webpack5 configuration'
      kv 'target_folder_base'     , target_folder_base
      kv 'global_template_folder' , global_template_folder
    end

    private

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end
  end
end
