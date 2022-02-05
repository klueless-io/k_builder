# frozen_string_literal: true

module KBuilder
  # TODO: Why is this called BaseBuilder, why not just builder
  # TODO: Is this really the builder pattern, it could be the class used by a director
  #       but it is not really storing information for builder purposes.
  #
  # Base builder defines builder methods, build method and configuration
  #
  # Convention: Setter methods (are Fluent) and use the prefix set_
  #             Getter methods (are NOT fluent) and return the stored value
  #             Setter methods (are NOT fluent) can be created as needed
  #             these methods would not be prefixed with the set_

  # process_any_content(content: 'abc')
  # process_any_content(content_file: 'abc.txt')
  # process_any_content(template: 'abc {{name}}', name: 'sean')
  # process_any_content(template_file: 'abc.txt', name: 'sean')

  # process_any_content(content_gist:  'https://gist.github.com/klueless-io/8d4b6d199dbe4a5d40807a47fff8ed1c')
  # process_any_content(template_gist: 'https://gist.github.com/klueless-io/8d4b6d199dbe4a5d40807a47fff8ed1c', name: 'sean')

  class BaseBuilder
    include KLog::Logging

    attr_reader :configuration

    attr_accessor :target_folders
    attr_accessor :template_folders

    attr_accessor :last_output_file
    attr_accessor :last_output_folder
    # attr_accessor :last_template
    attr_accessor :last_template_file

    # Factory method that provides a builder for a specified structure
    # runs through a configuration block and then builds the final structure
    #
    # @return [type=Object] data structure
    def self.build
      init.build
    end

    # Create and initialize the builder.
    #
    # @return [Builder] Returns the builder via fluent interface
    def self.init(configuration = nil)
      builder = new(configuration)

      yield(builder) if block_given?

      builder
    end

    # assigns a builder hash and defines builder methods
    def initialize(configuration = nil)
      configuration = KConfig.configuration if configuration.nil?

      @configuration = configuration

      @target_folders = configuration.target_folders.clone
      @template_folders = configuration.template_folders.clone
    end

    # @return [Hash/StrongType] Returns data object, can be a hash
    #                           or strong typed object that you
    #                           have wrapped around the hash
    def build
      raise NotImplementedError
    end

    def to_h
      {
        target_folders: target_folders.to_h,
        template_folders: template_folders.to_h
      }
    end

    # rubocop:disable Metrics/AbcSize
    def debug
      log.subheading 'kbuilder'

      log.kv 'current folder key' , current_folder_key
      log.kv 'current folder'     , target_folder
      target_folders.debug(title: 'target_folders')

      log.info ''

      template_folders.debug(title: 'template folders (search order)')

      log.info ''
      log.kv 'last output file'     , last_output_file
      log.kv 'last output folder'   , last_output_folder
      # log.kv 'last template'        , last_template
      log.kv 'last template file'   , last_template_file

      ''
    end
    # rubocop:enable Metrics/AbcSize

    # ----------------------------------------------------------------------
    # Fluent interface
    # ----------------------------------------------------------------------

    # Internal Actions are considered helpers for the builder, they do
    # something useful, but they do not tend to implement fluent interfaces.
    #
    # They some times do actions, they sometimes return information.
    #
    # NOTE: [SRP] - These methods should probably be converted into objects
    # ----------------------------------------------------------------------

    # Add a file to the target location
    #
    # @param [String] file The file name with or without relative path, eg. my_file.json or src/my_file.json
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be processed  ('nobody') From address
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    #
    # Extra options will be used as data for templates, e.g
    # @option opts [String] :to Recipient email
    # @option opts [String] :body The email's body
    def add_file_action(file, **opts)
      {
        action: :add_file,
        played: false,
        file: file,
        opts: opts
      }
    end

    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def add_file(file, **opts)
      # move to command
      full_file = target_file(file, **opts) # opts.key?(:folder_key) || opts.key?(:folder) ? target_file(file, folder: opts[:folder], folder_key: opts[:folder_key]) : target_file(file)

      # Need logging options that can log these internal details
      mkdir_p(File.dirname(full_file))

      content = process_any_content(**opts)

      file_write(full_file, content, on_exist: opts[:on_exist])

      # Prettier needs to work with the original file name
      run_prettier file                   if opts.key?(:pretty)
      # TODO: Add test
      run_cop(full_file, fix_safe: true)  if opts.key?(:cop) || opts.key?(:ruby_cop)
      # TODO: Add test
      run_command(file)                   if opts.key?(:run)

      # Need support for rubocop -a
      open_file(last_output_file)         if opts.key?(:open)
      open_file(last_template_file)       if opts.key?(:open_template)
      browse_file(last_output_file)       if opts.key?(:browse)
      pause(opts[:pause])                 if opts[:pause]

      self
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def play_actions(actions)
      actions.reject { |action| action[:played] }.each do |action|
        play_action(action)
      end
    end

    def play_action(action)
      run_action(action)
      action[:played] = true
    end

    # certain actions (e.g. set_current_folder) will run independently to play
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def run_action(action)
      case action[:action]
      when :add_file
        add_file(action[:file], action[:opts])
      when :delete_file
        delete_file(action[:file], action[:opts])
      when :vscode
        vscode(action[:file_parts], action[:opts])
      when :browse
        browse(action[:file_parts], action[:opts])
      when :set_current_folder
        set_current_folder(action[:folder_key])
      when :run_command
        run_command(action[:command])
      when :run_script
        run_script(action[:script])
      else
        log.error "Unknown action: #{action[:action]}"
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    alias touch add_file # it is expected that you would not supply any options, just a file name

    def delete_file_action(file, **opts)
      {
        action: :delete_file,
        played: false,
        file: file,
        opts: opts
      }
    end

    def delete_file(file, **opts)
      full_file = target_file(file, **opts) # = opts.key?(:folder_key) ? target_file(file, folder: opts[:folder_key]) : target_file(file)

      File.delete(full_file) if File.exist?(full_file)

      self
    end

    def file_exist?(file, **opts)
      # full_file = opts.key?(:folder_key) ? target_file(file, folder_key: opts[:folder_key]) : target_file(file)
      full_file = target_file(file, **opts)

      File.exist?(full_file)
    end

    # ToDo
    # def delete_folder(file)
    #   FileUtils.remove_dir(path_to_directory) if File.directory?(path_to_directory)

    #   self
    # end

    def make_folder(folder_key = nil, sub_path: nil)
      folder_key  = current_folder_key if folder_key.nil?
      folder      = target_folder(folder_key)
      folder      = File.join(folder, sub_path) unless sub_path.nil?

      mkdir_p(folder)

      self
    end

    # Add content to the clipboard
    #
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be processed  ('nobody') From address
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    #
    # Extra options will be used as data for templates, e.g
    # @option opts [String] :to Recipient email
    # @option opts [String] :body The email's body
    def add_clipboard(**opts)
      # move to command
      content = process_any_content(**opts)

      begin
        IO.popen('pbcopy', 'w') { |f| f << content }

        open_file(last_template_file) if opts.key?(:open_template)
      rescue Errno::ENOENT => e
        if e.message == 'No such file or directory - pbcopy'
          # May want to use this GEM in the future
          # https://github.com/janlelis/clipboard
          puts 'Clipboard paste is currently only supported on MAC'
        end
      end

      self
    end
    alias clipboard_copy add_clipboard

    def vscode_action(*file_parts, folder_key: current_folder_key, file: nil)
      {
        action: :vscode,
        played: false,
        file_parts: file_parts,
        opts: { folder_key: folder_key, file: file }
      }
    end

    def vscode(*file_parts, folder_key: current_folder_key, file: nil)
      # move to command
      file = target_file(*file_parts, folder_key: folder_key) if file.nil?

      rc "code #{file}"

      self
    end

    def browse_action(*file_parts, folder_key: current_folder_key, file: nil)
      {
        action: :browse,
        played: false,
        file_parts: file_parts,
        opts: { folder_key: folder_key, file: file }
      }
    end

    def browse(*file_parts, folder_key: current_folder_key, file: nil)
      # move to command
      file = target_file(*file_parts, folder_key: folder_key) if file.nil?

      rc "open -a \"Google Chrome\" #{file}"

      self
    end

    def open
      open_file(last_output_file)

      self
    end
    alias o open

    def open_template
      open_file(last_template_file)

      self
    end
    alias ot open_template

    def open_file(file)
      if file.nil?
        log.warn('open_file will not open when file is nil')
        return self
      end

      vscode(file: file)

      self
    end

    def browse_file(file)
      if file.nil?
        log.warn('browse_file will not browse when file is nil')
        return self
      end

      browse(file: file)

      self
    end

    def pause(seconds = 1)
      sleep(seconds)

      self
    end

    # ----------------------------------------------------------------------
    # Attributes: Think getter/setter
    #
    # The following getter/setters can be referenced both inside and outside
    # of the fluent builder fluent API. They do not implement the fluent
    # interface unless prefixed by set_.
    #
    # set_: Only setters with the prefix _set are considered fluent.
    # ----------------------------------------------------------------------

    # Target folders and files
    # ----------------------------------------------------------------------

    def set_current_folder_action(folder_key)
      {
        action: :set_current_folder,
        played: false,
        folder_key: folder_key
      }
    end

    def set_current_folder(folder_key)
      target_folders.current = folder_key

      self
    end
    alias cd set_current_folder

    # Fluent adder for target folder (KBuilder::NamedFolders)
    def add_target_folder(folder_key, value)
      target_folders.add(folder_key, value)

      self
    end

    def current_folder_key
      target_folders.current
    end

    # Get target folder by folder_key
    #
    # If folder_key not supplied then get the current target folder
    def target_folder(folder_key = current_folder_key)
      target_folders.get(folder_key)
    end

    # Get target file
    #
    # If you provide a relative folder, then it will be relative to the :folder parameter
    #
    # If the :folder is not set, then it will be relative to the current folder
    #
    # @examples
    #   target_file('abc.txt')
    #   target_file('xyz/abc.txt')
    #   target_file('xyz', 'abc.txt')
    #
    # If you provide an absolute folder, then it will ignore the :folder parameter
    #
    # @examples
    #   target_file('/abc.txt')
    #   target_file('/xyz/abc.txt')
    #   target_file('/xyz', 'abc.txt')
    def target_file(*file_parts, folder_key: current_folder_key, folder: nil, **)
      # TODO: Mismatch (sometimes called folder, sometimes called folder_key:)
      if folder
        log.error("Change folder: to folder_key: for #{folder} - #{file_parts}")
        return
      end

      # Absolute path
      return File.join(*file_parts) if Pathname.new(file_parts.first).absolute?

      # Relative to :folder_key
      File.join(target_folder(folder_key), *file_parts)
    end

    # Template folder & Files
    # ----------------------------------------------------------------------

    # Fluent adder for template folder (KBuilder::LayeredFolders)
    def add_template_folder(folder_key, value)
      template_folders.add(folder_key, value)

      self
    end

    # Get for template folder
    def get_template_folder(folder_key)
      template_folders.get(folder_key)
    end

    # Gets a template_file relative to the template folder, looks first in
    # local template folder and if not found, looks in global template folder
    def find_template_file(file_parts)
      self.last_template_file = template_folders.find_file(file_parts)
      last_template_file
    end

    # Building content from templates
    # ----------------------------------------------------------------------

    # Use content from a a selection of content sources
    #
    # @option opts [String] :content Just pass through the :content as is.
    # @option opts [String] :content_file Read content from the :content_file
    #
    # Future options
    # @option opts [String] :content_loren [TODO]Create Loren Ipsum text as a :content_loren count of words
    # @option opts [String] :content_url Read content from the :content_url
    #
    # @return Returns some content
    def use_content(**opts)
      return opts[:content] unless opts[:content].nil?

      return unless opts[:content_file]

      # NOTE: when using content file, you still want to search for it in the template folders, I THINK?
      cf = find_template_file(opts[:content_file])

      return "content not found: #{opts[:content_file]}" if cf.nil?

      File.read(cf)
    end

    # Use template from a a selection of template sources
    #
    # @option opts [String] :template Just pass through the :template as is.
    # @option opts [String] :template_file Read template from the :template_file
    #
    # @return Returns some template
    def use_template(**opts)
      return opts[:template] unless opts[:template].nil?

      return unless opts[:template_file]

      tf = find_template_file(opts[:template_file])

      return "template not found: #{opts[:template_file]}" if tf.nil?

      File.read(tf)
    end

    # Process content will take any one of the following
    #  - Raw content
    #  - File based content
    #  - Raw template (translated via handlebars)
    #  - File base template (translated via handlebars)
    #
    # Process any of the above inputs to create final content output
    #
    # @option opts [String] :content Supply the content that you want to write to the file
    # @option opts [String] :template Supply the template that you want to write to the file, template will be transformed using handlebars
    # @option opts [String] :content_file File with content, file location is based on where the program is running
    # @option opts [String] :template_file File with handlebars templated content that will be transformed, file location is based on the configured template_path
    def process_any_content(**opts)
      raw_content = use_content(**opts)

      return raw_content if raw_content

      template_content = use_template(**opts)

      Handlebars::Helpers::Template.render(template_content, opts) unless template_content.nil?
    end

    def run_cop(file, **opts)
      command = Commands::RuboCopCommand.new(file, builder: self, **opts)
      command.execute

      self
    end

    # Need to handle absolute files, see
    # /Users/davidcruwys/dev/printspeak/reference_application/printspeak-domain/.builders/presentation/presentation_builder/commands/copy_ruby_resource_command.rb
    def run_prettier(file, log_level: :log)
      # command = "prettier --check #{file} --write #{file}"
      command = "npx prettier --loglevel #{log_level} --write #{file}"

      run_command command
    end

    def run_command(command)
      # Deep path create if needed
      tf = target_folder

      mkdir_p(tf)

      build_command = "cd #{tf} && #{command}"

      puts build_command

      # need to support the fork process options as I was not able to run
      # k_builder_watch -n because it hid all the following output
      system(build_command)

      # FROM k_dsl
      # system "/usr/local/bin/zsh #{output_file}" if execution_context == :system
      # fork { exec("/usr/local/bin/zsh #{output_file}") } if execution_context == :fork
    end
    alias rc run_command

    def run_command_action(command)
      {
        action: :run_command,
        played: false,
        command: command
      }
    end

    # NOT TESTED, and not working with opts, this code needs rewrite
    def run_script(script)
      # Deep path create if needed
      tf = target_folder

      mkdir_p(tf)

      Dir.chdir(tf) do
        output, status = Open3.capture2(script) # , **opts)

        unless status.success?
          log.error('Script failed')
          puts script
          return nil
        end

        return output
      end
    end

    def run_script_action(script)
      {
        action: :run_script,
        played: false,
        script: script
      }
    end

    def file_write(file, content, on_exist: :skip)
      self.last_output_file = file # if file not found, we still want to record this as the last_output_file

      not_found = !File.exist?(file)

      if not_found
        File.write(file, content)
        return
      end

      return if %i[skip ignore].include?(on_exist)

      if %i[overwrite write].include?(on_exist)
        File.write(file, content)
        return
      end

      return unless on_exist == :compare

      vscompare(file, content)
    end

    def vscompare(file, content)
      # need to use some sort of caching folder for this
      ext = File.extname(file)
      fn  = File.basename(file, ext)
      temp_file = Tempfile.new([fn, ext])

      temp_file.write(content)
      temp_file.close

      return if File.read(file) == content

      system("code -d #{file} #{temp_file.path}")
      sleep 2
    end

    def mkdir_p(folder)
      @last_output_folder = FileUtils.mkdir_p(folder).first
    end
  end
end
