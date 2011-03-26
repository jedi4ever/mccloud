require 'json'
require 'logger'

require 'fog'

require 'mccloud/config'

require 'mccloud/command/status'
require 'mccloud/command/up'
require 'mccloud/command/halt'
require 'mccloud/command/ssh'
require 'mccloud/command/boot'
require 'mccloud/command/bootstrap'
require 'mccloud/command/reload'
require 'mccloud/command/multi'
require 'mccloud/command/init'
require 'mccloud/command/suspend'
require 'mccloud/command/destroy'

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
    
    include Mccloud::Command
    
    def initialize(options=nil)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG

      #http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/classes/Logger.html
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"

      #logger.formatter = proc { |severity, datetime, progname, msg|
      #   "#{datetime} - #{severity}: #{msg}\n"
      # }
      @session=self
      Mccloud.session=self
    end
    
    def load_config(options=nil)
      @logger.debug "Loading mccloud config"
      #if File.exist?(path)
      begin
        Kernel.load File.join(Dir.pwd,"Mccloudfile")
      rescue LoadError => e
        @logger.error "Error loading configfile - Sorry"
        @logger.error e.message  
        @logger.error e.backtrace.inspect  
        exit -1
      end

      @all_servers=Hash.new
      if File.exists?(".mccloud")
        
        @logger.debug ".mccloud exists"
        dotmccloud=File.new(".mccloud")
        
        @logger.debug "reading .mccloud json file"
        json=dotmccloud.readlines.to_s
        
        begin
          @logger.debug "parsing .mccloud json file"
          @all_servers=JSON.parse(json)
        rescue Error => e
          @logger.error "Error parsing json file - Sorry"
          @logger.error e.message  
          @logger.error e.backtrace.inspect  
          exit -1
        end
        
      end
      
      #Loading providers
      Mccloud.session.config.vms.each do |name,vm|
        @logger.debug "adding provider #{vm.provider}"
        @session.config.providers[vm.provider]=Fog::Compute.new(:provider => vm.provider)
      end
            
      invalid_cache=false
      @session.config.vms.each do |name,vm|
        prefix=@session.config.mccloud.prefix
        id=@all_servers["#{name.to_s}"]
        
        #Check if not destroyed or something else
        
        instance=vm.instance
        if instance.nil?
          @logger.error "Cache is invalid"
          invalid_cache=true
        else  
          if instance.state == "shutting-down" || instance.state == "terminated"
            @logger.info "parsing .mccloud json" 
            @logger.info "rebuilding cache"
            invalid_cache=true
          end
        end
      end
      
      #
      if (invalid_cache)
        #Resetting the list
        @all_servers=Hash.new

        servers_by_provider=Hash.new
      
        # Find all providers
        @session.config.providers.each do |name,provider|
          server_list=Hash.new
          provider.servers.each do |server|

            if !(server.state == "terminated")
                server_list[server.tags["Name"]]=server.id	
            end
          end
          servers_by_provider[name]=server_list
        end
        prefix=@session.config.mccloud.prefix
        
        @session.config.vms.each do |name,vm|
          id=servers_by_provider[vm.provider]["#{prefix} - #{name.to_s}"]
        

          if !id.nil?
            @all_servers[name]=id
            #@session.config.vms[name].instance=@session.config.providers[vm.provider].servers.get(id)
          end
        end
        
          dotmccloud=File.new(".mccloud","w")
          dotmccloud.puts(@all_servers.to_json)
          dotmccloud.close
          
       
      end
    end




  end
end