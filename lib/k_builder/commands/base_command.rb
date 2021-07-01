# frozen_string_literal: true

module KBuilder
  module Commands
    # Base command for single responsibility actions that can be fired
    # from methods in the builder.
    #
    # Uses the command pattern
    class BaseCommand
      include KLog::Logging

      attr_accessor :builder
      attr_accessor :valid

      def initialize(**opts)
        @builder = opts[:builder]
        @valid = true
      end

      def guard(message)
        # THIS SHOULD ONLY LOG IF DEBUGGING IS TURNED ON
        log.error(message)
        @valid = false
      end

      def valid?
        @valid
      end

      def debug(title: nil)
        log.section_heading(title) if title
        debug_values if respond_to?(:debug_values)
      end
    end
  end
end
