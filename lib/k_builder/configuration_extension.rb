# frozen_string_literal: true

# Attach configuration to the KBuilder module
module KBuilder
  module ConfigurationExtension
    # Target folders provide a set of named folders that can be written to
    def target_folders=(value)
      @target_folders = value
    end

    def target_folders
      @target_folders ||= KType::NamedFolders.new
    end

    # Template folders provides layered folders that templates can exist within
    def template_folders=(value)
      @template_folders = value
    end

    def template_folders
      @template_folders ||= KType::LayeredFolders.new
    end

    # Custom debug method for k_builder
    #
    # usage:
    #   config.debug(:k_builder_debug)
    def k_builder_debug
      target_folders.debug(title: 'target_folders')

      template_folders.debug(title: 'template folders (search order)')
      ''
    end
  end
end

KConfig::Configuration.include(KBuilder::ConfigurationExtension)
