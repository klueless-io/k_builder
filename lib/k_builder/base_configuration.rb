# frozen_string_literal: true

module KBuilder
  # Base configuration object for all k_builder* GEM
  class BaseConfiguration
    class << self
      # Attach a child configuration with it's own settings to a parent configuration
      #
      # @param [Class] klass_child what class would you like as the child
      # @param [Class] klass_parent what class would you like to extend with a new child configuration
      # @param [Symbol] accessor_name what is the name of the accessor that you are adding
      def attach_config_to_parent(klass_child, klass_parent, accessor_name)
        # Create a memoized getter to an instance of the attaching class (:klass_child)
        #
        # def third_party
        #   @third_party ||= KBuilder::ThirdPartyGem::Configuration.new
        # end
        klass_parent.send(:define_method, accessor_name) do
          return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

          instance_variable_set("@#{accessor_name}", klass_child.new)
        end
      end
      alias attach_to attach_config_to_parent
    end

    # move out into module
    def to_h
      hash = {}
      instance_variables.each do |var|
        value = instance_variable_get(var)

        value = KUtil.data.to_hash(value) if complex_type?(value)

        hash[var.to_s.delete('@')] = value
      end
      hash
    end

    # This code is being moved into k_util (data)
    # Any basic (aka primitive) type
    def basic_type?(value)
      value.is_a?(String) ||
        value.is_a?(Symbol) ||
        value.is_a?(FalseClass) ||
        value.is_a?(TrueClass) ||
        value.is_a?(Integer) ||
        value.is_a?(Float)
    end

    # Anything container that is not a regular class
    def complex_type?(value)
      value.is_a?(Array) ||
        value.is_a?(Hash) ||
        value.is_a?(Struct) ||
        value.is_a?(OpenStruct) ||
        value.respond_to?(:to_h)
    end

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end
  end
end
