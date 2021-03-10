# frozen_string_literal: true

# Attach configuration to the KBuilder module
module KBuilder
  # Context class provides instance specific configuration
  # and context to a builder class, by default it duplicates
  # any configuration data.
  #
  # Uses composition over inheritance
  class Context
    attr_accessor :target_folder_base
    attr_accessor :global_template_folder

    def initialize(config)
      @target_folder_base = config.target_folder_base.dup
      @global_template_folder = config.global_template_folder.dup
    end

    def debug
      puts '-' * 120
      puts 'kbuilder base context'
      kv 'target_folder_base'     , target_folder_base
      kv 'global_template_folder' , global_template_folder
    end

    private

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end
  end
end
