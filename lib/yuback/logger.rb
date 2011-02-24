#--
# Yuback::Logger
# Author      : kurt/yuweb <garnier.etienne@gmail.com>
# Description : Manage ruby programs log and output messages class.
#               Support loglevels, syslog, logfile and SDOUT 

require 'syslog'

module Yuback
  # Manage ruby programs log and output messages class.
  # Support loglevels, syslog, logfile and SDOUT.
  # LogsLevel: Debug, Info, Error, Silent
  class Logger

    attr_accessor :LOGLEVEL, :OUTPUT

    # Set up the logger
    #   logs = Yuback::Logger.new(:syslog => true, stdout => flase)
    #   logs.LOGLEVEL = "info"
    #
    def initialize(output = Hash.new)
      @LOGLEVEL = "error";
      @OUTPUT = Hash.new
      if !output[:stdout].nil? then
        @OUTPUT[:stdout] = output[:stdout]
      else
        @OUTPUT[:stdout] = true
      end
      @OUTPUT[:syslog] = output[:syslog] || false
      @OUTPUT[:logfile] = output[:logfile] || ""
      
      # Open a syslog connection if needed
      @syslog = Syslog.open("Yuback") if @OUTPUT[:syslog]

      # Open the logfile if needed
      @logfile = File.open(@OUTPUT[:logfile], "a+") if @OUTPUT[:logfile] != ""
      
      # Verify given informations
      raise ArgumentError, ":stdout must be boolean" if @OUTPUT[:stdout].class.to_s != "TrueClass" and @OUTPUT[:stdout].class.to_s != "FalseClass"
      raise ArgumentError, ":syslog must be boolean" if @OUTPUT[:syslog].class.to_s != "TrueClass" and @OUTPUT[:syslog].class.to_s != "FalseClass"
    end 

    # Send a message to the logguer
    def msg(message, level = "debug")
      # Verify the loglevel
      available = ["debug", "info", "error", "silent"]
      raise NotImplementedError, "Available loglevels: debug, info, error, silent" if !available.include?(@LOGLEVEL)

      # Route the messages
      case level
      when "debug"
        if @LOGLEVEL == "debug" then
          send_stdout("[#{level.capitalize}] #{message}") if @OUTPUT[:stdout]
          send_syslog(message, level) if @OUTPUT[:syslog]
          send_logfile("[#{level.capitalize}] #{message}\n") if @OUTPUT[:logfile] != ""
        end
      when "info"
         if @LOGLEVEL == "info" or @LOGLEVEL == "debug" then
           send_stdout("[#{level.capitalize}] #{message}") if @OUTPUT[:stdout]
           send_syslog(message, level) if @OUTPUT[:syslog]
           send_logfile("[#{level.capitalize}] #{message}\n") if @OUTPUT[:logfile] != ""
         end
      when "error"
        if @LOGLEVEL == "debug" or @LOGLEVEL == "info" or @LOGLEVEL == "error" then
          send_stdout("[#{level.capitalize}] #{message}") if @OUTPUT[:stdout]
          send_syslog(message, level) if @OUTPUT[:syslog] 
          send_logfile("[#{level.capitalize}] #{message}\n") if @OUTPUT[:logfile] != ""
        end
      when "silent"
        #do nothing
      else
        raise NotImplementedError, "Available loglevels: debug, info, error, silent"
      end
     
    end

    private
    # Send messages to console
    def send_stdout(msg)
      puts msg
    end

    # Send message to syslog
    def send_syslog(msg, level)
      @syslog.debug(msg) if level == "debug"
      @syslog.err(msg) if level == "error"      
    end

    # Send message to logfile
    def send_logfile(msg)
      @logfile.write(Time.new.to_s+" "+msg)
    end

  end
end
