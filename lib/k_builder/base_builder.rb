# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  #
  # Convention: Setter methods (are Fluent) and use the prefix set_
  #             Getter methods (are NOT fluent) and return the stored value
  #             Setter methods (are NOT fluent) can be created as needed
  #             these methods would not be prefixed with the set_
  class BaseBuilder
    attr_reader :configuration

    attr_accessor :target_folders

    attr_accessor :template_folders

    # Factory method that provides a builder for a specified structure
    # runs through a configuration block and then builds the final structure
    #
    # @return [type=Object] data structure
    def self.build
      init.build
    end

    # Create and initialize the builder.
    #
    # @return [Builder] Returns the builder via fluent interface
    def self.init(configuration = nil)
      builder = new(configuration)

      yield(builder) if block_given?

      builder
    end

    # assigns a builder hash and defines builder methods
    def initialize(configuration = nil)
      configuration = KBuilder.configuration if configuration.nil?

      @configuration = configuration

      @target_folders = configuration.target_folders.clone
      @template_folders = configuration.template_folders.clone

      define_builder_setter_methods
    end

    # Return an array of symbols to represent the fluent
    # setter methods that you want on your builder.
    #
    # Abstract method
    def builder_setter_methods
      []
    end

    # @return [Hash/StrongType] Returns data object, can be a hash
    #                           or strong typed object that you
    #                           have wrapped around the hash
    def build
      raise NotImplementedError
    end

    def to_h
      {
        target_folders: target_folders.to_h,
        template_folders: template_folders.to_h
      }
    end

    # ----------------------------------------------------------------------
    # Fluent interface
    # ----------------------------------------------------------------------

    # Internal Actions are considered helpers for the builder, they do
    # something useful, but they do not tend to implement fluent interfaces.
    #
    # They some times do actions, they sometimes return information.
    #
    # NOTE: [SRP] - These methods should probably be converted into objects
    # ----------------------------------------------------------------------

    # Add a file to the target location
    #
    # @param [String] file The file name with or without relative path, eg. my_file.json or src/my_file.json
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be processed  ('nobody') From address
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    #
    # Extra options will be used as data for templates, e.g
    # @option opts [String] :to Recipient email
    # @option opts [String] :body The email's body
    def add_file(file, **opts)
      full_file = target_file(file)

      FileUtils.mkdir_p(File.dirname(full_file))

      content = process_any_content(**opts)

      File.write(full_file, content)

      # Prettier needs to work with the original file name
      run_prettier file if opts.key?(:pretty)

      self
    end

    # ----------------------------------------------------------------------
    # Attributes: Think getter/setter
    #
    # The following getter/setters can be referenced both inside and outside
    # of the fluent builder fluent API. They do not implement the fluent
    # interface unless prefixed by set_.
    #
    # set_: Only setters with the prefix _set are considered fluent.
    # ----------------------------------------------------------------------

    # Target folders and files
    # ----------------------------------------------------------------------

    def set_current_folder(folder_key)
      target_folders.current = folder_key

      self
    end
    alias cd set_current_folder

    # Fluent adder for target folder (KBuilder::NamedFolders)
    def add_target_folder(folder_key, value)
      target_folders.add(folder_key, value)

      self
    end

    def current_folder_key
      target_folders.current
    end

    # Get target folder by folder_key
    #
    # If folder_key not supplied then get the current target folder
    def target_folder(folder_key = current_folder_key)
      target_folders.get(folder_key)
    end

    # Get target file
    def target_file(file_parts, folder: current_folder_key)
      File.join(target_folder(folder), file_parts)
    end

    # Template folder & Files
    # ----------------------------------------------------------------------

    # Fluent adder for template folder (KBuilder::LayeredFolders)
    def add_template_folder(folder_key, value)
      template_folders.add(folder_key, value)

      self
    end

    # Get for template folder
    def get_template_folder(folder_key)
      template_folders.get(folder_key)
    end

    # Gets a template_file relative to the template folder, looks first in
    # local template folder and if not found, looks in global template folder
    def find_template_file(file_parts)
      template_folders.find_file(file_parts)
    end

    # Building content from templates
    # ----------------------------------------------------------------------

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

    def run_prettier(file, log_level: :log)
      # command = "prettier --check #{file} --write #{file}"
      command = "npx prettier --loglevel #{log_level} --write #{file}"

      run_command command
    end

    def run_command(command)
      # Deep path create if needed
      tf = target_folder

      FileUtils.mkdir_p(tf)

      build_command = "cd #{tf} && #{command}"

      puts build_command

      system(build_command)
    end
    alias rc run_command

    # TODO
    # Support Nesting
    # Support Generation fo the following
    #   - fluent set_
    #   - Support setter (non-fluent)
    #   - Support getter (non-fluent)

    # # builds a nested structure by either builder block or hash
    # # @param data_structure [type=DataStructure]
    # # @param builder [type=Builder]
    # # @param attributes [type=Hash|DataStructure instance]
    # # @param &block
    # #
    # # @return [type=Hash]
    # def build_nested(data_structure, builder, attributes = {}, &block)
    #   if block_given?
    #     builder.build(&block).to_h
    #   else
    #     build_hash(data_structure, attributes)
    #   end
    # end

    private

    # #
    # # @param data_structure [type=DataStructure]
    # # @param attributes [type=Hash, DataStructure]
    # #
    # # @return [type=Hash]
    # def build_hash(data_structure, attributes)
    #   if attributes.is_a?(data_structure)
    #     attributes.to_h
    #   else
    #     data_structure.new(attributes).to_h
    #   end
    # end

    # Defines all of the necessary builder setter methods
    #
    # @return [Builder] Returns the builder via fluent interface
    def define_builder_setter_methods
      builder_setter_methods.each { |method| define_builder_method(method) }
      self
    end

    # Defines a method using the convention set_[method_name]
    #
    # Convention: Setter methods (are Fluent) and use the prefix set_
    #             Getter methods (are NOT fluent) and return the stored value
    #
    # @return [Builder] Returns the builder via fluent interface
    def define_builder_method(method_name)
      self.class.send(:define_method, "set_#{method_name}") do |value|
        @hash[method_name.to_s] = value
        self
      end
    end
  end
end
