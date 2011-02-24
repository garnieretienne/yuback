#--
# Yuback::Application
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Web Application class.
#               Support for cache dirs, sources and framework, 
#               databases (file and SQL/NoSQL).

require 'yaml'
require 'yuback/framework'
require 'yuback/database'
require 'yuback/files_database'
require 'yuback/cache_dir'

module Yuback
  # Web application with cache, framework 
  # and databases support (Files, SQL/NoSQL).
  class Application

    attr_accessor :path
    attr_reader :name, :frameworks, :databases, :files_databases, :cache_dirs, :profile

    # Init a new application :
    #   appli = Yuback::Application.new(:name => "appli_name", :path => "/path/to/app") 
    #   appli.add_database(Yuback::Database.new("yumail"))
    #   appli.add_framework(Yuback::Framework.new("folder_framework"))
    #   appli.add_framework(Yuback::Framework.new("css_framework_folder"))
    #   appli.add_files_database(Yuback::FilesDatabase.new("uploads"))
    #   appli.add_cache_dir(Yuback::CacheDir.new("sessions_dir"))
    #   ...
    # or:
    #   appli = Yuback::Application.new(:profile => "/path/to/profile.yml")
    #
    def initialize(options = Hash.new)
      @databases = Array.new
      @frameworks = Array.new
      @files_databases = Array.new
      @cache_dirs = Array.new
      raise ArgumentError, "No name+path or profile specified" if options[:path].nil? and options[:profile].nil?
      raise ArgumentError, "#{options[:path]} doesn't exist" if options[:profile].nil? and !File.exist?(options[:path])
      raise ArgumentError, "No application name specified" if options[:profile].nil? and options[:name].nil?
      if options[:profile] then
        @profile = options[:profile]
        load_profile(options[:profile])
      else
        @profile = nil
        @name = options[:name]
        @path = options[:path]
      end
    end

    # Add a database to the application
    def add_database(database)
      raise ArgumentError, "Given parameter is not a valid database" if database.class.to_s != "Yuback::Database"
      @databases << database
    end

    # Add a framework to the application
    def add_framework(framework)
      raise ArgumentError, "Given parameter is not a valid framework" if framework.class.to_s != "Yuback::Framework"
      @frameworks << framework
    end

    # Add a dynamic files folder to the application
    def add_files_database(fdb)
      raise ArgumentError, "Given parameter is not a valid files database folder" if fdb.class.to_s != "Yuback::FilesDatabase"
      @files_databases << fdb
    end

    # Declare a cache directory on the application
    def add_cache_dir(cd)
      raise ArgumentError, "Given parameter is not a valid cache dir" if cd.class.to_s != "Yuback::CacheDir"
      @cache_dirs << cd
    end

    # Load a config file in yml format:
    #   config:
    #     name: Yumail
    #     desc: Yuweb Webmail
    #     domain: yumail.yuweb.fr
    #     sources: /home/kurt/yumail
    #   
    #   cache_dirs:
    #     - name: session
    #       folder: cache
    #     - name: phantom
    #       folder: false
    #   
    #   frameworks:
    #     - name: kajax
    #
    #   files_databases:
    #     - name: uploads
    #
    #   databases:
    #     - name: yumail
    #
    def load_profile(path)
      raw_config = File.read(path)
      app_config = YAML.load(raw_config)
      raise ArgumentError, "Profile file is empty" if !app_config
      raise ArgumentError, "Profile does't contain any application name" if app_config["config"]["name"].nil?
      raise ArgumentError, "Profile does't contain any application path" if app_config["config"]["sources"].nil?
      @name = app_config["config"]["name"]
      @path = app_config["config"]["sources"]
      if app_config["frameworks"] then
        app_config["frameworks"].each do |framework|
          raise ArgumentError, "Bad framework definition, no name defined" if framework["name"].nil?
          fm = Yuback::Framework.new(framework["name"])
          fm.folder = framework["folder"] if !framework["folder"].nil?
          self.add_framework(fm)
        end
      end
      if app_config["databases"] then
        app_config["databases"].each do |database|
          raise ArgumentError, "Bad database definition, no name defined" if database["name"].nil?
          db = Yuback::Database.new(database["name"])
          db.type = database["type"] if !database["type"].nil?
          self.add_database(db)
        end
      end
      if app_config["files_databases"] then
        app_config["files_databases"].each do |files_database|
          raise ArgumentError, "Bad files database definition, no name defined" if files_database["name"].nil?
          fdb = Yuback::FilesDatabase.new(files_database["name"])
          fdb.folder = files_database["folder"] if !files_database["folder"].nil?
          self.add_files_database(fdb)          
        end
      end
      if app_config['cache_dirs'] then
        app_config["cache_dirs"].each do |cache_dir|
          raise ArgumentError, "Bad files cache folder definition, no name defined" if cache_dir["name"].nil?
          cd = Yuback::CacheDir.new(cache_dir["name"])
          cd.folder = cache_dir["folder"] if !cache_dir["folder"].nil?
          self.add_cache_dir(cd)          
        end
      end
    end

    # Display the summary of the application
    def to_s
      app = "Application: #{@name}\n"
      app = app + "       Path: #{@path}"

      if !@cache_dirs.empty? then
        if @cache_dirs.count == 1 then
          app = app + "\n  Cache Dir: #{@cache_dirs.first}"
        else
          app = app + "\n Cache Dirs:"
          @cache_dirs.each do |cd|
            app = app + "\n           - #{cd}"
          end
        end
      end

      if !@frameworks.empty? then
        if @frameworks.count == 1 then
          app = app + "\n  Framework: #{@frameworks.first}"
        else
          app = app + "\n Frameworks:"
          @frameworks.each do |fm|
             app = app + "\n           - #{fm}"
          end
        end
      end

      if !@databases.empty? then
        if @databases.count == 1 then
          app = app + "\n   Database: #{@databases.first}"
        else
          app = app + "\n  Databases:"
          @databases.each do |db|
            app = app + "\n           - #{db}"
          end
        end
      end

      if !@files_databases.empty? then
        if @files_databases.count == 1 then
          app = app + "\n  Files dir: #{@files_databases.first}"
        else
          app = app + "\n Files dirs:"
          @files_databases.each do |fdb|
            app = app + "\n           - #{fdb}"
          end
        end
      end

      return app
    end
    
  end
end
