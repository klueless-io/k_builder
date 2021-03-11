# frozen_string_literal: true

module KBuilder
  # Base builder defines builder methods, build method and configuration
  class BaseBuilder
    attr_reader :hash

    # Factory method that provides a builder for a specified structure
    # runs through a configuration block and then builds the final structure
    #
    # @return [type=Object] data structure
    def self.build
      builder = new

      # block.call(builder) if !block.nil?
      yield(builder) if block_given?

      builder.build
    end

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

    #
    # defines a method
    # @param method_name [type=String]
    #
    # @return [type=Symbol] e.g. method symbol
    def define_builder_method(method_name)
      self.class.send(:define_method, method_name) do |value|
        @hash[method_name.to_s] = value
        self
      end
    end
  end
end
