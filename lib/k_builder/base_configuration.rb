# frozen_string_literal: true

module KBuilder
  # Base configuration object for all k_builder* GEM
  class BaseConfiguration
    def to_hash
      hash = {}
      instance_variables.each { |var| hash[var.to_s.delete('@')] = instance_variable_get(var) }
      hash
    end

    def kv(name, value)
      puts "#{name.rjust(30)} : #{value}"
    end

    # All of this code should be extracted into a module
    #
    # The module should then be extracted out into a GEM so that
    # I can include it as needed. The GEM might be called
    # (dynamic attributes) and would allow a regular class to act like an OpenStruct
    # K-DSL uses data hash, while base configuration uses instance variables

    def respond_to_missing?(name, *_args, &_block)
      # puts 'respond_to_missing?'
      # puts "respond_to_missing: #{name}"
      n = name.to_s
      n = n[0..-2] if n.end_with?('=')

      if n.end_with?('?')
        super
      else
        # This has not been fully tested
        instance_variable_defined?("@#{n}") || super
      end
    end

    def method_missing(name, *args, &_block)
      # puts "method_missing: #{name}"
      # puts "args.length   : #{args.length}"

      add_getter_or_param_method(name)
      add_setter_method(name)

      send(name, args[0]) if args.length == 1 # name.end_with?('=')

      super unless self.class.method_defined?(name)
    end

    # Handles Getter method and method with single parameter
    # object.my_name
    # object.my_name('david')
    def add_getter_or_param_method(name)
      # L.progress(1, 'add_getter_or_param_method')
      self.class.class_eval do
        # L.progress(2, 'add_getter_or_param_method')
        name = name.to_s.gsub(/=$/, '')
        # L.progress(3, 'add_getter_or_param_method')
        # L.kv 'name', name
        define_method(name) do |*args|
          # L.progress(4, 'add_getter_or_param_method')
          # L.kv 'add_getter_or_param_method', name
          raise KBuilder::Error, 'Multiple setting values is not supported' if args.length > 1

          if args.length.zero?
            get_value(name)
          else
            send("#{name}=", args[0])
          end
        end
      end
    end

    # Handles Setter method
    # object.my_name = 'david'
    def add_setter_method(name)
      # L.progress(1, 'add_setter_method')
      self.class.class_eval do
        # L.progress(2, 'add_setter_method')
        name = name.to_s.gsub(/=$/, '')
        # L.progress(3, 'add_setter_method')
        # L.kv 'add_setter_method', name
        define_method("#{name}=") do |value|
          # L.progress(4, 'add_setter_method')
          # L.kv 'name', name
          # L.kv 'value', value
          instance_variable_set("@#{name}", value)
          # my_data[name.to_s] = value
        end
      end
    end

    def get_value(name)
      instance_variable_get("@#{name}")
    end
  end

  # class L
  #   def self.progress(index, label)
  #     puts "#{index} - #{label}"
  #   end

  #   def self.kv(name, value)
  #     puts "#{name.rjust(30)} : #{value}"
  #   end
  # end
end
