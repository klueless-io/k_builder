# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  class Builder < KBuilder::BaseBuilder
    BUILDER_METHODS = %w[
      target_folder
      template_folder
      template_folder_global
    ].freeze

    def initialize(configuration = nil)
      super()

      if configuration.nil?
        hash.merge!(KBuilder.configuration.to_hash)
      elsif configuration.is_a?(Hash)
        hash.merge!(configuration)
      else
        raise KBuilder::StandardError, 'Unknown configuration object'
      end
    end

    # def build
    #   # SomeDryStruct.new(hash)
    # end

    def builder_methods
      BUILDER_METHODS
    end
  end
end
