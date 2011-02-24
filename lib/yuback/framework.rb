#--
# Yuback::Framework
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Web Application framework class.
#               Support for not backup the framework.

module Yuback
  # Web Application framework class.
  # Support for not backup the framework.
  class Framework

    attr_accessor :folder
    attr_reader :name

    # Specify a framework folder.
    # Frameworks specifieds here will not be backuped by Yuback::Backup.
    #   framework_to_not_include_in_the_backup = Yuback::Framework.new("kajax")
    def initialize(name, folder=name)
      @name   = name
      @folder = folder
    end

    # Print the framework name and folder
    def to_s
      "#{@name} (#{@folder})"
    end

  end
end
