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

    def initialize_copy(orig)
      super(orig)

      @target_folders = orig.target_folders.clone
      @template_folders = orig.template_folders.clone
    end

    # rubocop:disable Metrics/AbcSize
    def debug
      L.subheading 'kbuilder base configuration'

      L.section_heading 'target_folders'
      target_folders.folders.each_key do |key|
        folder = target_folders.folders[key]
        L.kv key.to_s, folder
      end
      L.info ''

      L.section_heading 'template folders (search order)'

      template_folders.ordered_keys.each do |key|
        folder = template_folders.folders[key]
        L.kv key.to_s, folder
      end
      ''
    end
    # rubocop:enable Metrics/AbcSize
  end
end
