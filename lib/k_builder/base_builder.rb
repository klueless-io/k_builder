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

    # Fluent adder for target folder (KBuilder::NamedFolders)
    def add_target_folder(folder_key, value)
      target_folders.add(folder_key, value)

      self
    end

    # Get target folder
    def get_target_folder(folder_key)
      target_folders.get(folder_key)
    end

    # Get target file
    def target_file(file_parts, folder: nil)
      File.join(get_target_folder(folder), file_parts)
    end

    # Target folder
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
