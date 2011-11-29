require 'mccloud/config'

require 'mccloud/command/init'
require 'mccloud/command/provider'
require 'logger'

module Mccloud

  # Represents a single Mccloud environment. A "Mccloud environment" is
  # defined as basically a folder with a "Mccloudfile". This class allows
  # access to the VMs, CLI, etc. all in the scope of this environment
  class Environment

    include Mccloud::EnvironmentCommand

    # The `cwd` that this environment represents
    attr_reader :cwd

    # The valid name for a Mccloudfile for this environment
    attr_reader :mccloudfile_name

    # The {UI} Object to communicate with the outside world
    attr_writer :ui

    # The configuration as loaded by the Mccloudfile
    attr_accessor :config

    #    attr_accessor :providers


    def initialize(options=nil)
      options = {
        :cwd => nil,
        :mccloudfile_name => nil}.merge(options || {})

       # We need to set this variable before the first call to the logger object
       if options.has_key?("debug")
         ENV['MCCLOUD_LOG']="STDOUT"
         ui.info "Debugging enabled"
       end


        # Set the default working directory to look for the Mccloudfile
        options[:mccloudfile_name] ||=["Mccloudfile",""]

        logger.info("environment") { "Environment initialized (#{self})" }
        logger.info("environment") { " - cwd : #{cwd}" }

        options.each do |key, value|
          instance_variable_set("@#{key}".to_sym, options[key])
        end

        return self
    end

    #---------------------------------------------------------------
    # Config Methods
    #---------------------------------------------------------------

    # The configuration object represented by this environment. This
    # will trigger the environment to load if it hasn't loaded yet (see
    # {#load!}).
    #
    # @return [Config::Top]
    def config
      load! if !loaded?
      @config
    end

    # Returns the {UI} for the environment, which is responsible
    # for talking with the outside world.
    #
    # @return [UI]
    def ui
      @ui ||=  UI.new(self)
    end

    #---------------------------------------------------------------
    # Load Methods
    #---------------------------------------------------------------

    # Returns a boolean representing if the environment has been
    # loaded or not.
    #
    # @return [Bool]
    def loaded?
      !!@loaded
    end

    # Loads this entire environment, setting up the instance variables
    # such as `vm`, `config`, etc. on this environment. The order this
    # method calls its other methods is very particular.
    def load!
      if !loaded?
        @loaded = true

        logger.info("environment") { "Loading configuration..." }
        load_config!

        self
      end
    end

    ## Does the actual read of the configuration file
    ## @return [self]
    def load_config!

      # Read the config
      @config=Config.new({:env => self}).load_mccloud_config()

      # Read the templates in the template sub-dir
      @config.load_templates

      # Read the vms specified inthe vm sub-dir
      @config.load_vms
      @ui.info "Loaded #{@config.providers.length} providers "+"#{@config.vms.length} vms"+" #{@config.ips.length} ips"+" #{@config.stacks.length} stacks"+" #{@config.templates.length} templates"

      return self
    end

    # Reloads the configuration of this environment.
    def reload_config!
      @config = nil
      load_config!
      self
    end

    # Makes a call to the CLI with the given arguments as if they
    # came from the real command line (sometimes they do!). An example:
    #
    #     env.cli("package", "--mccloudfile", "Mccloudfile")
    #
    def cli(*args)
      CLI.start(args.flatten, :env => self)
    end

    def resource
      "mccloud"
    end

    # Accesses the logger for Vagrant. This logger is a _detailed_
    # logger which should be used to log internals only. For outward
    # facing information, use {#ui}.
    #
    # @return [Logger]
    def logger
      return @logger if @logger

      # Figure out where the output should go to.
      output = nil
      if ENV["MCCLOUD_LOG"] == "STDOUT"
        output = STDOUT
      elsif ENV["MCCLOUD_LOG"] == "NULL"
        output = nil
      elsif ENV["MCCLOUD_LOG"]
        output = ENV["MCCLOUD_LOG"]
      else
        output = nil #log_path.join("#{Time.now.to_i}.log")
      end

      # Create the logger and custom formatter
      @logger = ::Logger.new(output)
      @logger.formatter = Proc.new do |severity, datetime, progname, msg|
        "#{datetime} - #{progname} - [#{resource}] #{msg}\n"
      end

      @logger
    end

  end #Class
end #Module
