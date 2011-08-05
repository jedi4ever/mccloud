require 'json'
require 'logger'


require 'fog'
require 'highline'
require 'highline/import'

require 'mccloud/config'

require 'mccloud/command/status'
require 'mccloud/command/up'
require 'mccloud/command/halt'
require 'mccloud/command/ssh'
require 'mccloud/command/boot'
require 'mccloud/command/bootstrap'
require 'mccloud/command/loadbalance'
require 'mccloud/command/sorry'
require 'mccloud/command/reload'
require 'mccloud/command/multi'
require 'mccloud/command/init'
require 'mccloud/command/ips'
require 'mccloud/command/suspend'
require 'mccloud/command/destroy'
require 'mccloud/command/flavors'
require 'mccloud/command/provision'
require 'mccloud/command/server'
require 'mccloud/command/package'
require 'mccloud/command/deregister'

require 'mccloud/type/vm'
require 'mccloud/util/sshkey'

module Mccloud

  # We need some global thing for the config file to find our session
  def self.session=(value)
    @session=value
  end
  def self.session
    return @session
  end

  class Session
    attr_accessor :config
    attr_accessor :logger
    attr_accessor :all_servers
    attr_accessor :all_stacks

    include Mccloud::Command

    def initialize(options=nil)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG

      #http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/classes/Logger.html
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"

      @session=self
      Mccloud.session=self
    end

    def load_config(options=nil)
      load_configfile(options)
      load_resources(options)
    end

    def load_configfile(options=nil)
      @logger.debug "Loading mccloud config"
      #if File.exist?(path)
      begin
        Kernel.load File.join(Dir.pwd,"Mccloudfile")
      rescue LoadError => e
        @logger.error "Error loading configfile - Sorry"
        @logger.error e.message  
#        @logger.error e.backtrace.inspect  
        exit -1
      end
    end
    
    def load_resources(options=nil)
      
      # Requiring the provider ruby modules
      provider_path=File.join(File.dirname(__FILE__),"provider")
      Dir.glob("#{provider_path}/*.rb").each do |filename|
          require "#{filename}"
      end
      
      all_resources=[ @config.stacks , @config.vms , @config.lbs , @config.ips]

      # Loading providers for all resources
      all_resources.each do |resources|
        resources.each do |name,resource|
          puts "Resource - #{name} - #{resource.provider}"
          provider=Object.const_get("Mccloud").const_get("Provider").const_get(resource.provider.capitalize).new(resource.provider_options)
          provider.load(self)
        end
      end

      # For each provider load the resources
      @session.config.providers.each do |name,provider|
        filter=@session.config.mccloud.filter
        #stack_filter=@session.config.mccloud.stackfilter
        
        # get all resources running on each provider (filtered)
        provider.load_resources(filter)
      end

    end

  end
end
