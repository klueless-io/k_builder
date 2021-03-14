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

    def to_hash
      hash = {}
      instance_variables.each do |var|
        value = instance_variable_get(var)

        value = value.to_hash if value.is_a?(KBuilder::BaseConfiguration)

        hash[var.to_s.delete('@')] = value
      end
      hash
    end

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end
  end
end
