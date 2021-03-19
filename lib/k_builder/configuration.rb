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
    attr_accessor :target_folders
    attr_accessor :template_folders

    def initialize
      super
      # @target_folder = Dir.getwd
      # @template_folder = File.join(Dir.getwd, '.templates')
      # @global_template_folder = nil
      @target_folders = NamedFolders.new
      @template_folders = LayeredFolders.new
    end

    # rubocop:disable Metrics/AbcSize
    def debug
      puts '-' * 120
      puts 'kbuilder base configuration'

      puts 'target_folders'
      target_folders.folders.each_key do |key|
        folder = target_folders.folders[key]
        kv key.to_s, folder
      end

      puts 'template folders (search order)'
      template_folders.ordered_folders.each do |folder|
        puts folder.to_s
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
