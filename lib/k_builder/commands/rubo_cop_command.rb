# frozen_string_literal: true

module KBuilder
  module Commands
    # Run RuboCop against a file
    class RuboCopCommand < BaseCommand
      attr_reader :file_pattern
      attr_reader :fix_safe
      attr_reader :fix_unsafe
      attr_reader :rubo_config_file
      attr_reader :show_console

      attr_reader :cop_options
      attr_reader :cop_opt_values

      # Initialize RuboCop command
      #
      # @param [String] file_pattern File name or file pattern
      # @param [Hash] **opts The options
      # @option opts [Boolean] :fix_safe RuboCop -a option will fix simple and safe issues
      # @option opts [Boolean] :fix_unsafe RuboCop -A option will fix simple but potentially unsafe issues
      # @option opts [Boolean] :show_console This will show in console, or if false set --out ~/last_cop.txt so that console is redirected to file
      # @option opts [String] :rubo_config_file YAML file with RuboCop configuration options
      #
      # @example Cop for single file with auto fix turned on for simple issues
      #
      #   RubCopCommand.new('abc.rb', fix_safe: true)
      #
      # @example Cop for all spec files to auto simple and unsafe issues
      #
      #   RubCopCommand.new('spec/**/*.rb', fix_unsafe: true)
      def initialize(file_pattern, **opts)
        super(**opts)

        @valid = true

        self.file_pattern       = file_pattern

        self.fix_safe           = opts[:fix_safe]
        self.fix_unsafe         = opts[:fix_unsafe]
        self.show_console       = opts[:show_console]
        self.rubo_config_file   = opts[:rubo_config_file]
      end

      def execute
        return unless valid?

        cop_run
      end

      def cli_options
        cli_options = []
        # quite is the same as simple, except you will see nothing if no offenses
        cli_options << '--format' << 'quiet' # 'simple'
        cli_options << '-a' if fix_safe
        cli_options << '-A' if fix_unsafe
        cli_options << '--config' << rubo_config_file if rubo_config_file
        cli_options << '--out' << File.expand_path('~/last_cop.txt') unless show_console
        cli_options << file_pattern
        cli_options
      end

      def debug_values
        log.kv 'rubocop target', file_pattern
        log.kv '-a', 'automatic fix for safe issues'                  if fix_safe
        log.kv '-A', 'automatic fix for potentially unsafe issues'    if fix_unsafe
        log.kv '-config', rubo_config_file                            if rubo_config_file
      end

      private

      def file_pattern=(value)
        @file_pattern = value

        if value.nil? || value.empty?
          guard 'file_pattern is required'
        elsif Pathname.glob(value).length.zero?
          guard 'file_pattern does not reference an existing file'
        end
      end

      def fix_safe=(value)
        @fix_safe = value || false
      end

      def fix_unsafe=(value)
        @fix_unsafe = value || false
      end

      def show_console=(value)
        @show_console = value || false
      end

      def rubo_config_file=(value)
        @rubo_config_file = value

        return if value.nil? || value.empty?

        guard("Unknown RuboCop config file: #{value}") unless File.exist?(value)
      end

      def cop_run
        cli = RuboCop::CLI.new

        # log.section_heading('CLI OPTIONS')
        # log.block cli_options

        cli.run(cli_options)
      end
    end
  end
end
