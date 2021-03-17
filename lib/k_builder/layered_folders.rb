# frozen_string_literal: true

module KBuilder
  # Layered folders allow files to be found in any of the search folders
  #
  # Preference is given to folders that are registered last.
  # Order is (First In, Last Out) priority aka a Stack (Last In, First Out)
  #
  # Put your most global folder in first and your more targeted folders in later
  #
  # example:
  #   folders = LayeredFolders.new
  #   folders.add('~/global_templates')
  #   folders.add('/my-project/domain_templates')
  #   folders.add('/my-project/my-app/.templates')
  #
  # Search will start with app_templates, then domain_templates and then finally global templates
  class LayeredFolders
    attr_reader :folders

    def initialize
      @folders = []
    end

    def add(folder)
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
