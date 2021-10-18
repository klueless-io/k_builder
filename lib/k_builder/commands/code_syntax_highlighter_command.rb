# frozen_string_literal: true

module KBuilder
  module Commands
    # Run CodeSyntaxHighlighter against source code and produce a styled HTML representation
    #
    # Alternatives to Highlighter-js could be carbon-now and ray.so
    class CodeSyntaxHighlighterCommand < BaseCommand
      attr_reader :source_code
      attr_reader :formatted_code

      def initialize(source_code, **opts)
        super(**opts)

        self.source_code = source_code
      end

      def execute
        return unless valid?

        run
      end

      private

      def source_code=(value)
        @source_code = value

        guard('Source code is required for formatting') if value.nil? || value.empty?
      end

      def run
        # @formatted_code = ExecJS.eval("'red yellow blue'.split(' ')")

        # # highlight_source = 'lib/k_builder/assets/a.js'
        # highlight_source = 'lib/k_builder/assets/highlight.min.js'

        # log.error ExecJS.runtime.name

        # a = File.read(highlight_source)
        # # context = ExecJS.compile(a)
        # context = ExecJS.compile(highlight_source)
        # context.call("html = hljs.highlightAuto('<h1>Hello World!</h1>').value")

        # get_js_asset('highlight')
        # get_js_asset('ruby')
      end

      # https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.0.1/highlight.min.js
      # https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.0.1/languages/ruby.min.js

      def get_js_asset(name)
        url = "https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.0.1/#{name}.min.js"
        target_folder = 'lib/k_builder/assets'
        file = "#{name}.min.js"

        get_asset(url, target_folder, file)
      end

      def get_asset(url, target_folder, file)
        local_asset_file = File.join(target_folder, file)

        return if File.exist?(local_asset_file)

        content = Net::HTTP.get(URI.parse(url))

        File.write(local_asset_file, content)
      end
    end
  end
end
