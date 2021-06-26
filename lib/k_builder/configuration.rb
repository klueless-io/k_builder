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

  # Does this class need to move out into k_types?
  # It is being used with k_manager in a similar fashion
  #
  # Configuration class
  class Configuration < BaseConfiguration
    include KLog::Logging

    # Target folders provide a set named folders that can be written to
    attr_accessor :target_folders

    # Template folders provides layered folders that templates can exist within
    attr_accessor :template_folders

    def initialize
      super
      # @target_folder = Dir.getwd
      # @template_folder = File.join(Dir.getwd, '.templates')
      # @global_template_folder = nil
      @target_folders = KType::NamedFolders.new
      @template_folders = KType::LayeredFolders.new
    end

    def initialize_copy(orig)
      super(orig)

      @target_folders = orig.target_folders.clone
      @template_folders = orig.template_folders.clone
    end

    def debug
      log.subheading 'kbuilder base configuration'

      target_folders.debug(title: 'target_folders')

      log.info ''

      template_folders.debug(title: 'template folders (search order)')
      ''
    end
  end
end
