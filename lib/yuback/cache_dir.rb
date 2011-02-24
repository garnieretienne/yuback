#--
# Yuback::CacheDir
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Web Application cache directory class.
#               Support for cache dirs. Their content is temp, 
#               they don't have to be saved.


module Yuback
  # Support for cache dirs. Their content is temp, 
  # they don't have to be saved.
  class CacheDir

    attr_accessor :folder
    attr_reader :name

    # Specify a cache folder:
    #   cache_files = Array.new
    #   cache_files << Yuback::CacheDir.new("cache")
    #   cache_files << Yuback::CacheDir.new("static_cache", "statics")
    def initialize(name, folder=name)
      @name = name
      @folder = folder
    end

    # Print the cache folder name
    def to_s
      "#{@name} (#{@folder})"
    end

  end
end
