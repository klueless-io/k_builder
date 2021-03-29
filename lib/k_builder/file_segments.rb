# frozen_string_literal: true

module KBuilder
  # Splits a file into its base parts (file, path, file_name, extension and file_name_only)
  #
  # Provides the interpolate helper to rebuild a different filename using those segments
  class FileSegments
    attr_reader :file
    attr_reader :path
    attr_reader :file_name
    attr_reader :ext
    attr_reader :file_name_only

    def initialize(file)
      @file = file
      @path = File.dirname(file)
      @file_name = File.basename(file)
      @ext = File.extname(file)
      @file_name_only = File.basename(file, @ext)
    end

    def interpolate(target_file)
      # p str.gsub( /#{var}/, 'foo' )   # => "a test foo"
      target_file
        .gsub(/\$T_FILE\$/i, file)
        .gsub(/\$T_PATH\$/i, path)
        .gsub(/\$T_FILE_NAME\$/i, file_name)
        .gsub(/\$T_EXT\$/i, ext)
        .gsub(/\$T_FILE_NAME_ONLY\$/i, file_name_only)
    end
  end
end
