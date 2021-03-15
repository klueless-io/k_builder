# frozen_string_literal: true

# Attach data helper to the KBuilder module
module KBuilder
  # Data helpers/utils for Kbuilder
  class << self
    attr_writer :data
  end

  def self.data
    @data ||= DataHelper.new
  end

  # Helper methods attached to the namespace for working with Data
  #
  # Usage: KBuilder.data.to_struct(data)
  class DataHelper
    # Convert a hash into a deep OpenStruct or array an array
    # of objects into an array of OpenStruct
    def to_struct(data)
      case data
      when Hash
        OpenStruct.new(data.transform_values { |v| to_struct(v) })

      when Array
        data.map { |o| to_struct(o) }

      else
        # Some primitave type: String, True/False, Symbol or an ObjectStruct
        data
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def struct_to_hash(data)
      # No test yet
      if data.is_a?(Array)
        return data.map { |v| v.is_a?(OpenStruct) ? struct_to_hash(v) : v }
      end

      data.each_pair.with_object({}) do |(key, value), hash|
        case value
        when OpenStruct
          hash[key] = struct_to_hash(value)
        when Array
          # No test yet
          values = value.map { |v| v.is_a?(OpenStruct) ? struct_to_hash(v) : v }
          hash[key] = values
        else
          hash[key] = value
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    def clean_symbol(value)
      return value if value.nil?

      value.is_a?(Symbol) ? value.to_s : value
    end
  end
end
