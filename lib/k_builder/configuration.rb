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
    attr_accessor :target_folder
    attr_accessor :template_folder
    attr_accessor :template_folder_global

    def initialize
      @target_folder = Dir.getwd
      @template_folder = File.join(Dir.getwd, '.templates')
      @template_folder_global = nil
    end

    def debug
      puts '-' * 120
      puts 'kbuilder base configuration'
      kv 'target_folder'         , target_folder
      kv 'template_folder'       , template_folder
      kv 'template_folder_global', template_folder_global
    end

    def to_hash
      hash = {}
      instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
      hash
    end

    private

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end
  end
end
