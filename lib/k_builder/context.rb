# frozen_string_literal: true

module KBuilder
  # Context is a data object holding onto state.
  #
  # You can configure this object dynamically, it gets initialized
  # via the configuration class, but you can alter dynamically via
  # command line or builder
  class Context
    attr_accessor :root_target_folder
    attr_accessor :global_template_folder

    def initialize(config)
      self.config = config

      @target_folder = config.target_folder
      @template_folder = config.template_folder

      yield(self) if block_given?
    end

    private

    attr_reader :config
  end
end
