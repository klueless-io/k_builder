# frozen_string_literal: true

module KBuilder
  # Context is a data object holding onto state that is used when building webpack configuration.
  class BaseBuilder
    attr_accessor :context

    # Base build requires context data to store state,
    def initialize(context = nil)
      self.context = if context.nil?
                       KBuilder.configuration.dup
                     else
                       context
                     end
    end

    def output_path
      @output_path ||= File.expand_path(context.target_folder)
    end

    def target_file(file)
      File.expand_path(File.join(output_path, file))
    end

    def template_path
      @template_path ||= File.expand_path(context.template_folder)
    end

    def template_file(file)
      File.expand_path(File.join(template_path, file))
    end

    # Add a file to the target location
    #
    # @param [String] file The file name with or without relative path, eg. myfile.json or src/myfile.json
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be processed  ('nobody') From address
    # @option opts [String] :to Recipient email
    # @option opts [String] :body ('') The email's body
    def add_file(file, **opts)
      file = target_file(file)

      FileUtils.mkdir_p(File.dirname(file))

      content = transform_content(**opts)

      File.write(file, content)

      run_prettier file if opts.key?(:pretty)

      self
    end

    # Transform content will take any one of the following
    #  - Raw content
    #  - File based content
    #  - Template (via handlebars)
    #  - File base template
    # and convert the input to final content output
    #
    # @param [String] file The file name with or without relative path, eg. my_file.json or src/my_file.json
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be transformed using handlebars
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    def transform_content(**opts)
      result = handle_content(**opts)

      return result if result

      template = if !opts[:template].nil?
                   opts[:template]
                 elsif !opts[:template_file].nil?
                   tf = template_file(opts[:template_file])
                   return "Template not found: #{opts[:template_file]}" unless File.exist?(tf)

                   File.read(tf)
                 end

      return '' if template.nil?

      Handlebars::Helpers::Template.render(template, opts)
    end

    def handle_content(**opts)
      return opts[:content] unless opts[:content].nil?

      return unless opts[:content_file]

      cf = opts[:content_file]
      return "Content not found: #{File.expand_path(cf)}" unless File.exist?(cf)

      File.read(cf)
    end

    def run_prettier(file)
      command = "prettier --check #{file} --write #{file}"
      run_command command
    end

    def run_command(command)
      # Deep path create if needed
      FileUtils.mkdir_p(output_path)

      build_command = "cd #{output_path} && #{command}"

      system(build_command)
    end
    alias rc run_command
  end
end
