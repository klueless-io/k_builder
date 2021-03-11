# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  class Builder < KBuilder::BaseBuilder
    # builder_setter_methods = %w[].freeze
    # target_folder
    # template_folder
    # template_folder_global

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

    # rubocop:disable Metrics/AbcSize
    def after_new
      # ensure that any configured folders are expanded
      self.target_folder = hash['target_folder'] unless hash['target_folder'].nil?
      self.template_folder = hash['template_folder'] unless hash['template_folder'].nil?
      self.template_folder_global = hash['template_folder_global'] unless hash['template_folder_global'].nil?
    end
    # rubocop:enable Metrics/AbcSize

    # def build
    #   # SomeDryStruct.new(hash)
    # end

    # ----------------------------------------------------------------------
    # Attributes: The following getter/setters can be referenced outside of
    #             the builder fluent API
    # set_      : Only setters with the prefix _set are considered fluent.
    # ----------------------------------------------------------------------

    # Target folder
    # ----------------------------------------------------------------------

    # Fluent setter for target folder
    def set_target_folder(value)
      self.target_folder = value

      self
    end

    # Setter for target folder
    def target_folder=(value)
      hash['target_folder'] = File.expand_path(value)
    end

    # Getter for target folder
    def target_folder
      hash['target_folder']
    end

    # Template folder
    # ----------------------------------------------------------------------

    # Fluent setter for template folder
    def set_template_folder(value)
      self.template_folder = value

      self
    end

    # Setter for template folder
    def template_folder=(value)
      hash['template_folder'] = File.expand_path(value)
    end

    # Getter for template folder
    def template_folder
      hash['template_folder']
    end

    # Global Target folder
    # ----------------------------------------------------------------------

    # Fluent setter for global template folder
    def set_template_folder_global(value)
      self.template_folder_global = value

      self
    end

    # Setter for global template folder
    def template_folder_global=(value)
      hash['template_folder_global'] = File.expand_path(value)
    end

    # Setter for global template folder
    def template_folder_global
      hash['template_folder_global']
    end

    # Global Target folder
    # ----------------------------------------------------------------------

    def target_file(file)
      File.join(target_folder, file)
    end

    def builder_setter_methods
      []
    end
  end
end
