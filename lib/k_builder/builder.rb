# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  class Builder < KBuilder::BaseBuilder
    # builder_setter_methods = %w[].freeze
    # target_folder
    # template_folder
    # template_folder_global

    def initialize(configuration = nil)
      configuration = KBuilder.configuration.to_hash if configuration.nil?

      super(configuration)
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
    # Attributes: Think getter/setter
    #
    # The following getter/setters can be referenced both inside and outside
    # of the fluent builder fluent API. They do not implement the fluent
    # interface unless prefixed by set_.
    #
    # set_: Only setters with the prefix _set are considered fluent.
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

    # Internal Actions are considered helpers for the builder, they do
    # something useful, but they do not tend to implement fluent interfaces.
    #
    # They some times do actions, they sometimes return information.
    #
    # NOTE: [SRP] - These methods should probably be converted into objects
    # ----------------------------------------------------------------------

    # Gets a target_file relative to target folder
    def target_file(file)
      File.join(target_folder, file)
    end

    # Supply content from a content sources
    #
    # @option opts [String] :content Just pass through the :content as is.
    # @option opts [String] :content_file Read content from the :content_file
    #
    # Future options
    # @option opts [String] :content_loren [TODO]Create Loren Ipsum text as a :content_loren count of words
    # @option opts [String] :content_url Read content from the :content_url
    #
    # @return Returns some content
    def supply_content(**opts)
      return opts[:content] unless opts[:content].nil?

      return unless opts[:content_file]

      cf = opts[:content_file]
      return "Content not found: #{File.expand_path(cf)}" unless File.exist?(cf)

      File.read(cf)
    end

    def builder_setter_methods
      []
    end
  end
end
