#--
# Yuback::Exec
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Execution class (bin/yuback)

require 'rubygems'
require 'optparse'
require 'ostruct'
require 'yuback/application'
require 'yuback/logger'
require 'yuback/backup'
require 'yuback/config'

module Yuback
  class Exec

    def initialize
      begin
        # Start the logger
        @logger = Yuback::Logger.new({
          :syslog => false,
          :logfile => false,
          :stdout => true,
        })
        @logger.LOGLEVEL = "info"

        # Define options
        @opts = OptionParser.new
        options = OpenStruct.new
        options.config = nil # no config file loaded per default
        default_cf = "/etc/yuback/yuback.conf" # default config file
        options.config = default_cf if File.file?(default_cf)
        @opts.banner = "Usage: yuback [options] profile"
        @opts.on("-h", "--help", "Display this help") { print_help }
        @opts.on("-c", "--config CONFIG", String, "Config file path, \n\t\t\t\t\tdefault #{options.config}") { |val| options.config = val }
        @opts.on("-p", "--pool PATH", String, "Path to the pool") { |val| options.pool = val }
        backup_opts = %w{src sources db databases f files}
        @opts.on("-b", "--backup src,db,f", Array, "Backup only sources, databases or files") do |val|
          val.each do |bopt|
            print_help if !backup_opts.include?(bopt)
          end
options.backup_sources = true if val.include?("src") or val.include?("sources")
          options.backup_databases = true if val.include?("db") or val.include?("databases")
          options.backup_files = true if val.include?("f") or val.include?("files")
        end

        # Parse ARGV options and get the profile
        @logger.msg("Parse options and get profile")
        rest = @opts.parse(ARGV)
        raise ArgumentError, "Bad Arguments" if rest.count != 1
        profile = rest.last
        raise ArgumentError, "Profile: no file found" if !File.exist?(profile)

        # If no -b is given, backup all by default
        if !options.backup_sources and !options.backup_databases and !options.backup_files then
          options.backup_sources = true
          options.backup_databases = true
          options.backup_files = true
        end

        # Read config
        if options.config != nil then
          @logger.msg("Parse option file #{options.config}")
        else
          @logger.msg("No config file loaded")
        end
        config = Yuback::Config.new(options.config)

        # Load application
        @logger.msg("Load the application")
        app = Yuback::Application.new(:profile => profile )

        # Backup the application
        backup = Yuback::Backup.new(app)
        if options.backup_sources then
          @logger.msg("Backup sources")
          backup.sources
        end
        if options.backup_files then
          @logger.msg("Backup files")
          backup.files_databases
        end
        if options.backup_databases then
          @logger.msg("Backup databases")
          #TODO: suport for multi-databases, others databases types
          backup.databases(
            :mysql_server => config.mysql.server,
            :mysql_port => config.mysql.port,
            :mysql_user => config.mysql.user,
            :mysql_pass => config.mysql.pass)
        end
        @logger.msg("Application '#{app.name}' successfully backed up", "info")
      rescue Exception => e
        # Errors display
        @logger.msg("#{e.message}, -h for help", "error")
        Process.exit
      end
    end

    private
    def print_help
      @logger.msg(@opts.to_s, "info")
      Process.exit
    end

  end
end
