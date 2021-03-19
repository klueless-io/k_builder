# frozen_string_literal: true

module KBuilder
  # Base configuration object for all k_builder* GEM
  class BaseConfiguration
    def self.attach_to(klass_me, klass_target, accessor_name)
      # Create a memoized getter to an instance of the attaching class (:klass_me)
      #
      # def third_party
      #   @third_party ||= KBuilder::ThirdPartyGem::Configuration.new
      # end
      klass_target.send(:define_method, accessor_name) do
        return instance_variable_get("@#{accessor_name}") if instance_variable_defined?("@#{accessor_name}")

        instance_variable_set("@#{accessor_name}", klass_me.new)
      end
    end

    # move out into module
    def to_h
      hash = {}
      instance_variables.each do |var|
        value = instance_variable_get(var)

        if complex_type?(value)
          value = KBuilder.data.struct_to_hash(value)
        elsif value.is_a?(KBuilder::BaseConfiguration)
          value = value.to_hash
        end

        hash[var.to_s.delete('@')] = value
      end
      hash
    end

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
