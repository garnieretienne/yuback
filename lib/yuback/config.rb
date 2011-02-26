#--
# Yuback::Config
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Configuration class.
#               Support for config file, mysql credentials, email notifier, etc..

require 'yaml'

module Yuback
  # Configuration class.
  # Support for config file, mysql credentials, email notifier, etc..
  class Config

    attr_reader :mysql

    # Init a new config file.
    # Use the default config file (/etc/yuback/yuback.conf):
    #   config = Yuback::Config.new
    # Specify the config file:
    #   config = Yuback::Config.new("/path/to/config/file")
    def initialize(config_file=nil)
      # mysql credentials
      @mysql = OpenStruct.new
      @mysql.server = "localhost"
      @mysql.port = 3306
      @mysql.user = "root"
      @mysql.pass = ""

      if config_file then 
        if  File.file?(config_file) then
          @config_file = config_file
          verify
          load
        else
          raise ArgumentError, "Config: #{config_file} not found !"
        end
      end
    end

    private
    # Verify the owner and the security mode of the file. 
    # This file can contain sensitive informations and must authorize acces only in r+w for the owner.
    def verify
      raise SecurityError, "#{@config_file} (#{File.stat(@config_file).uid}:#{File.stat(@config_file).gid}) is not owned by the current user (#{`whoami`.chomp}[#{Process.uid}]:#{`id -ng`.chomp}[#{Process.gid}])" if File.stat(@config_file).uid != Process.uid or File.stat(@config_file).gid != Process.gid
      raise SecurityError, "#{@config_file} is not secure (600)" if File.stat(@config_file).mode.to_s(8) != "100600"
    end

    # Load parameters from the config file
    def load
      raw_config = File.read(@config_file)
      config = YAML.load(raw_config)
      if config then
        if !config["mysql"].nil? then
          @mysql.server = config["mysql"]["server"] if !config["mysql"]["server"].nil?
          @mysql.port = config["mysql"]["port"] if !config["mysql"]["port"].nil?
          @mysql.user = config["mysql"]["user"] if !config["mysql"]["user"].nil?
          @mysql.pass = config["mysql"]["pass"] if !config["mysql"]["pass"].nil?
        end
      end
      #TODO: mail alert
    end

  end
end
