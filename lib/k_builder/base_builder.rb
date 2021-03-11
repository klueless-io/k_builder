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

    def self.init(configuration = nil)
      builder = new(configuration)

      # Useful for massaging hash values that come in via configuration
      builder.after_new

      # May want a post initialize event so that concepts like
      # target_folder can be expanded and stored into the hash

      # block.call(builder) if !block.nil?
      yield(builder) if block_given?

      builder
    end

    def after_new; end

    # assigns a builder hash and defines builder methods
    def initialize
      @hash = {}
      define_builder_methods
    end

    def builder_methods
      raise NotImplementedError
    end

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

    #
    # defines all of the necessary builder methods
    #
    # @return [type] [description]
    def define_builder_methods
      builder_methods.each { |method| define_builder_method(method) }
      self
    end

    # Defines a method using the convention set_[method_name]
    #
    # Convention: Setter methods (are Fluent) and use the prefix set_
    #             Getter methods (are NOT fluent) and return the stored value
    def define_builder_method(method_name)
      self.class.send(:define_method, "set_#{method_name}") do |value|
        @hash[method_name.to_s] = value
        self
      end
    end
  end
end
