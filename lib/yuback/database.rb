#--
# Yuback::Database
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Web Application database class.
#               Support for databases (SQL/NoSQL).

module Yuback
  # Web Application database class.
  # Support for databases (SQL/NoSQL).

  class Database

    attr_accessor :type
    attr_reader :name

    # Specify a database
    #   databases = Array.new
    #   databases << Yuback::Database.new("database_name")
    def initialize(name, type="mysql")
      @name = name
      @type = type
    end

    # Print the database name
    def to_s
      "#{@name} (#{@type})"
    end

  end
end
