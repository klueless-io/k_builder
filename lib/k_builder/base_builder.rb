# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  #
  # Convention: Setter methods (are Fluent) and use the prefix set_
  #             Getter methods (are NOT fluent) and return the stored value
  #             Setter methods (are NOT fluent) can be created as needed
  #             these methods would not be prefixed with the set_
  class BaseBuilder
    attr_reader :hash

    # Factory method that provides a builder for a specified structure
    # runs through a configuration block and then builds the final structure
    #
    # @return [type=Object] data structure
    def self.build
      init.build
    end

    # Create and initialize the builder.
    #
    # Initialization can be done via any of these three sequential steps.
    #   - Configuration hash
    #   - After new event
    #   - Configuration block (lambda)
    #
    # @return [Builder] Returns the builder via fluent interface
    def self.init(configuration = nil)
      builder = new(configuration)

      builder.after_new

      yield(builder) if block_given?

      builder
    end

    # Use after_new to massage hash values that come in via
    # configuration into more complex values
    #
    # Abstract method
    def after_new; end

    # assigns a builder hash and defines builder methods
    def initialize
      @hash = {}
      define_builder_setter_methods
    end

    # Return an array of symbols to represent the fluent
    # setter methods that you want on your builder.
    #
    # Abstract method
    def builder_setter_methods
      raise NotImplementedError
    end

    # @return [Hash/StrongType] Returns data object, can be a hash
    #                           or strong typed object that you
    #                           have wrapped around the hash
    def build
      hash
    end

    # builds a nested structure by either builder block or hash
    # @param data_structure [type=DataStructure]
    # @param builder [type=Builder]
    # @param attributes [type=Hash|DataStructure instance]
    # @param &block
    #
    # @return [type=Hash]
    def build_nested(data_structure, builder, attributes = {}, &block)
      if block_given?
        builder.build(&block).to_h
      else
        build_hash(data_structure, attributes)
      end
    end

    private

    #
    # @param data_structure [type=DataStructure]
    # @param attributes [type=Hash, DataStructure]
    #
    # @return [type=Hash]
    def build_hash(data_structure, attributes)
      if attributes.is_a?(data_structure)
        attributes.to_h
      else
        data_structure.new(attributes).to_h
      end
    end

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
