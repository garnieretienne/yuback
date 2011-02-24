#--
# Yuback::Backup
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Backup class for web application.
#               Support sources, databases and files databases backup.
#               Compress with bzip2 for files and gunzip for databases.

require 'libarchive_ruby'
require 'find'

module Yuback
  # Backup module for Yuweb (yuweb.fr)
  class Backup

    attr_accessor :dir
    attr_reader :application, :date

    # Init an application backup
    #   appli  = Yuback::Application.new(:profile => "/path/to/profile.yml")
    #   backup = Yuback::Backup.new(appli)
    def initialize(application)
      raise ArgumentError, "Given parameter is not a valid application" if application.class.to_s != "Yuback::Application"
      @application = application
      @dir = "./"
      @date = Time.now
    end

    # Backup sources
    #   backup = Yuback::Backup.new(appli)
    #   backup.sources
    def sources
      name = name_forge({
        :name => @application.name,
        :type => "sources",
      })
      Archive.write_open_filename("#{name}.tar.bz2", Archive::COMPRESSION_BZIP2, Archive::FORMAT_TAR_USTAR) do |ar|
        Find.find(@application.path) do |path|
          if has_to_backup?(path)
            ar.new_entry do |entry|
              entry.copy_stat(path)
              newpath = path.split("/") - @application.path.split("/")
              entry.pathname = newpath.join("/")
              ar.write_header(entry)
              ar.write_data(open(path) {|f| f.read }) if !File.directory?(path)
            end
          end
        end
        # Add EMPTY cache and file databases folders
        @application.cache_dirs.each do |cd|
          ar.new_entry do |entry|
            entry.copy_stat( @application.path+"/"+cd.folder)
            entry.pathname = cd.folder
            ar.write_header(entry)
          end
        end
        @application.files_databases.each do |fdb|
          ar.new_entry do |entry|
            entry.copy_stat( @application.path+"/"+fdb.folder)
            entry.pathname = fdb.folder
            ar.write_header(entry)
          end
        end 
      end 
    end

    # Backup databases
    #   backup = Yuback::Backup.new(appli)
    #   backup.databases
    def databases(options = Hash.new)
      # default values
      options[:mysql_server] = "localhost" if options[:mysql_server].nil?
      options[:mysql_port] = "3306" if options[:mysql_port].nil?
      options[:mysql_user] = "root" if options[:mysql_user].nil?
      options[:mysql_pass] = "" if options[:mysql_pass].nil?

      @application.databases.each do |database|
        if database.type == "mysql" then # if mysql
          verify_mysqldump
          #TODO: replace system mysqldump by a more scalable method
          name = name_forge({
            :name  => @application.name,
            :type  => "database",
            :label => database.name,
          })
          system "mysqldump -h #{options[:mysql_server]} -P #{options[:mysql_port]} -u #{options[:mysql_user]} -p#{options[:mysql_pass]} #{database.name} | gzip > #{name}.sql.gz"
        #TODO: elsif another database
        end
      end
    end

    # Backup dynamic files storage folders
    #   backup = Yuback::Backup.new(appli)
    #   backup.sources
    def files_databases
      @application.files_databases.each do |fdb|
        name = name_forge({
            :name  => @application.name,
            :type  => "folder",
            :label => fdb.name,
          })
        Archive.write_open_filename("#{name}.tar.bz2", Archive::COMPRESSION_BZIP2, Archive::FORMAT_TAR_USTAR) do |ar|
        Find.find("#{@application.path}/#{fdb.folder}") do |path|
          ar.new_entry do |entry|
            entry.copy_stat(path)
            newpath = path.split("/") - @application.path.split("/")
            entry.pathname = newpath.join("/")
            ar.write_header(entry)
            ar.write_data(open(path) {|f| f.read }) if !File.directory?(path)
          end
        end
      end

      end
    end

    private
    # Verify than mysqldump is installed on the host
    def verify_mysqldump
      raise ArgumentError, "mysqldump (/usr/bin/mysqldump) is not installed on this host" if !File.file?("/usr/bin/mysqldump")
    end

    # Do not backup caches files or files from databases in source backup
    def has_to_backup?(path)
      
      # Take off the application name
      newpath = path.split("/") - @application.path.split("/")
      path = newpath.join("/")

      # Array of non-backup folder (cache dirs and files from databases)
      no_backup = Array.new

      # Files from databases
      @application.files_databases.each do |fdb|
        no_backup << fdb.folder
      end

      # Files from cache
      @application.cache_dirs.each do |cd|
        no_backup << cd.folder
      end

      # Files from framesworks
      @application.frameworks.each do |fm|
        no_backup << fm.folder
      end

      # Don't backup the path if it's a no_backup files 
      path_splitted = path.split("/")
      no_backup.each do |dir|
        dir_splitted = dir.split("/")
        recurse = dir_splitted.count - 1
        return false if dir_splitted[0..recurse] == path_splitted[0..recurse]
      end

      return true
    end

    # Forge a name for the archive
    # Must specify:
    #  - an application name (:name)
    #  - a label for folders and databases (:label)
    #  - a backup type (sources OR mysql OR folder) (:type)
    def name_forge(options)
      
      # Application name
      appli = options[:name]
      name = Array.new
      appli.split.each do |word|
        name << word.capitalize
      end
      name = name.join('_')
      # Backup label (for folders and databases names) if specified
      label = String if options[:label]
      if options[:label] then
        label = options[:label]
        label = "#{label.capitalize}-"
      end
      # Backup type (sources, database, folder ?)
      type = options[:type]
      if type == 'sources' then
        type = "SRC"
      elsif type == 'mysql' then
        type = "DB.MySQL"
      elsif type == 'folder' then
        type = "FOLDER"
      end
      # Backup date
      date = @date.strftime("%Y%m%d")
      # Backup timestamp
      timestamp = @date.to_i
      # Backup extention
      ext = String.new
      if type != "database" then
        ext = "sql.gz"
      else
        ext = "tar.bz2"
      end
      # Return the filename
      return "#{name}-#{label}#{type}-#{date}-#{timestamp}.#{ext}"
    end

  end
end
