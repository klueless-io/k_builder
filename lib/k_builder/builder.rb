# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  class Builder < KBuilder::BaseBuilder
    # builder_setter_methods = %w[].freeze
    # target_folder
    # template_folder
    # global_template_folder

    def initialize(configuration = nil)
      configuration = KBuilder.configuration.to_hash if configuration.nil?

      super(configuration)
    end

    # rubocop:disable Metrics/AbcSize
    def after_new
      # ensure that any configured folders are expanded
      self.target_folder = hash['target_folder'] unless hash['target_folder'].nil?
      self.template_folder = hash['template_folder'] unless hash['template_folder'].nil?
      self.global_template_folder = hash['global_template_folder'] unless hash['global_template_folder'].nil?
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
    def set_global_template_folder(value)
      self.global_template_folder = value

      self
    end

    # Setter for global template folder
    def global_template_folder=(value)
      hash['global_template_folder'] = File.expand_path(value)
    end

    # Setter for global template folder
    def global_template_folder
      hash['global_template_folder']
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

    # Gets a template_file relative to the template folder
    def template_file(file)
      File.join(template_folder, file)
    end

    # Gets a global_template_file relative to the global template folder
    def global_template_file(file)
      File.join(global_template_folder, file)
    end

    # Gets a template_file relative to the template folder, looks first in
    # local template folder and if not found, looks in global template folder
    def find_template_file(file)
      full_file = template_file(file)
      return full_file if File.exist?(full_file)

      full_file = global_template_file(file)
      return full_file if File.exist?(full_file)

      # File not found
      nil
    end

    # Use content from a a selection of content sources
    #
    # @option opts [String] :content Just pass through the :content as is.
    # @option opts [String] :content_file Read content from the :content_file
    #
    # Future options
    # @option opts [String] :content_loren [TODO]Create Loren Ipsum text as a :content_loren count of words
    # @option opts [String] :content_url Read content from the :content_url
    #
    # @return Returns some content
    def use_content(**opts)
      return opts[:content] unless opts[:content].nil?

      return unless opts[:content_file]

      cf = opts[:content_file]

      return "Content not found: #{File.expand_path(cf)}" unless File.exist?(cf)

      File.read(cf)
    end

    # Use template from a a selection of template sources
    #
    # @option opts [String] :template Just pass through the :template as is.
    # @option opts [String] :template_file Read template from the :template_file
    #
    # @return Returns some template
    def use_template(**opts)
      return opts[:template] unless opts[:template].nil?

      return unless opts[:template_file]

      tf = find_template_file(opts[:template_file])

      return "template not found: #{opts[:template_file]}" if tf.nil?

      File.read(tf)
    end

    # Process content will take any one of the following
    #  - Raw content
    #  - File based content
    #  - Raw template (translated via handlebars)
    #  - File base template (translated via handlebars)
    #
    # Process any of the above inputs to create final content output
    #
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be transformed using handlebars
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    def process_any_content(**opts)
      raw_content = use_content(**opts)

      return raw_content if raw_content

      template_content = use_template(**opts)

      Handlebars::Helpers::Template.render(template_content, opts) unless template_content.nil?
    end

    def builder_setter_methods
      []
    end
  end
end
