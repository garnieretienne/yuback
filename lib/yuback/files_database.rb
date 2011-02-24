#--
# Yuback::FilesDatabase
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Web Application Files Database class.
#               Support file directory database.

module Yuback
  # Web Application Files Database class.
  # Support dynamic file storage folder.
  class FilesDatabase

    attr_accessor :folder
    attr_reader :name

    # Specify a file storage folder
    #   files_folders = Array.new
    #   files_folders << Yuback::FilesDatabase.new("uploads")
    #   files_folders << Yuback::FilesDatabase.new("photos", "pictures/photos") 
    def initialize(name, folder=name)
      @name = name
      @folder = folder
    end

    # Print a file storage folder name
    def to_s
      "#{@name} (#{@folder})"
    end

  end
end
