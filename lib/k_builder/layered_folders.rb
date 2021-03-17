# frozen_string_literal: true

module KBuilder
  # Layered folders allow files to be found in any of the searchable folders
  #
  # Preference is given to folders that are registered last.
  # Order is (First In, Last Out) priority aka a Stack (Last In, First Out)
  #
  # Layered folders makes sense for use with template files and source data/model
  # where you can have specific usage files and/or fall-back files.
  #
  # Put your most global folder in first and your more targeted folders in later
  #
  # example:
  #   folders = LayeredFolders.new
  #   folders.add('~/global_templates')
  #   folders.add('/my-project/domain_templates')
  #   folders.add('/my-project/my-app/.templates')
  #
  #   # Find a file and folder will in folders in this order
  #   # app_templates, then domain_templates and then finally global templates
  #   # ['/my-project/my-app/.templates', '/my-project/domain_templates', '~/global_templates']
  #   #
  #   # Find a file called template1.txt and return its fully-qualified path
  #   folders.find_file('template1.txt')
  #
  #   # As above, but returns the folder only, file name and sub-paths are ignored
  #   folders.find_file_folder('template1.txt')
  #   folders.find_file_folder('abc/xyz/deep-template.txt')
  class LayeredFolders
    attr_reader :folders

    def initialize
      @folders = []
    end

    def add(folder)
      folder = File.expand_path(folder) if folder.start_with?('~')
      folders.prepend(folder)
    end

    # File name or array of sub-paths plus file
    #
    # Return the folder that a file is found in
    def find_file(file_parts)
      folder = find_file_folder(file_parts)
      folder.nil? ? nil : File.join(folder, file_parts)
    end

    # File name or array of sub-paths plus file
    #
    # Return the folder that a file is found in
    def find_file_folder(file_parts)
      folders.find { |folder| File.exist?(File.join(folder, file_parts)) }
    end
  end
end
