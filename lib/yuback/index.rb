#--
# Yuback::Index
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Index class with recursive folder and symlink support.

require 'find'

module Yuback

  # Index a directory recursively with symlinks support.
  # Symlinks supported:
  # - relative and absolute
  # - file and folder
  # - loop detection (by symlinks level authorized)
  class Index

    attr_reader :hash
    attr_accessor :level

    # Index a directory recursively, return a hash
    #   dir = "/tmp"
    #   index = Yuback::Index.new(dir)
    # Or with a symlinks level of 5 symlinks authorized
    #   index = Yuback::Index.new(dir, 5)
    # Print the index (debug)
    #   index.print
    #
    # Symlinks loop protector level:
    #
    # Authorise 20 symlinks level per default
    # Change it with:
    #   Yuback::Index.level = 100
    def initialize(dir, level = 20)
      @level = level
      @hash = Hash.new
      @keys = Hash.new
      build_index(dir)
    end

    # Print the indexed folder hash
    def print
      @hash.keys.each do |path|
        puts "#{path} => #{@hash[path]}"
        puts "#{index.hash.count} FILES INDEXED"
      end
    end

    private

    # Build an index for the directory specified
    def build_index(dir, prefix=nil)
      files = Hash.new
      if File.exist?(dir) then
        Find.find(dir) do |file|
          if file != dir then
            virtual_path = "#{prefix}#{path_sub(file, dir)}"
            if File.symlink?(file) then
              # Change directory for relative symlinks support
              chdir = file.split('/')
              chdir.delete_at(chdir.rindex(chdir.last))
              chdir = chdir.join('/')
              Dir.chdir(chdir)
              # Tranform relative file path to absolute file path if needed
              path = File.expand_path(File.readlink(file))
              if File.file?(path) then
                @hash["#{virtual_path}"] = path
              else
                # Symlink loop protection
                @keys[path] = 0 if !@keys[path]
                @keys[path] = @keys[path] + 1
                raise SecurityError, "Symlinks loop suspected, level: #{@level}, #{@hash.keys.count} files indexed" if @keys[path] >= @level
                build_index(path, "#{virtual_path}/")
              end
            else
              if @hash.has_key?(virtual_path) then
                raise SecurityError, "Two system file/folder have the same index: \n\t- #{virtual_path} => #{@hash[virtual_path]} \n\t- #{virtual_path} => #{file}"
              else
                @hash["#{virtual_path}"] = file
              end
            end
          end
        end
      end
    end

    # Path substraction,
    # return path1 - path2
    def path_sub(path1, path2)
      a_path1 = path1.split('/')
      a_path2 = path2.split('/')
      index_to_cut = a_path2.count
      a_path1.slice!(0, index_to_cut)
      return a_path1.join('/')
    end
  end
end
