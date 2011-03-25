require 'json'
require 'logger'

require 'fog'
PROVIDER=Fog::Compute.new(:provider => 'AWS')


module Mccloud
  
  def self.session=(value)
    @session=value
  end
  def self.session
    return @session
  end
  
  class Session
    attr_accessor :config
    attr_accessor :logger
    
    def initialize(options=nil)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG

      #http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/classes/Logger.html
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"

      #logger.formatter = proc { |severity, datetime, progname, msg|
      #   "#{datetime} - #{severity}: #{msg}\n"
      # }
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
      
      invalid_cache=false
      Mccloud::Config.config.vms.each do |definedvm|
        vm=definedvm[1]
        name=vm.name.to_s
        prefix=Mccloud::Config.config.mccloud.prefix
        id=@all_servers["#{prefix} - #{name}"]
        #Check if not destroyed or something else
        server=PROVIDER.servers.get(id)
        if server.nil?
          invalid_cache=true
        else  
          if server.state == "shutting-down" || server.state == "terminated"
            @logger.info "parsing .mccloud json" "rebuilding cache"
            invalid_cache=true
          end
        end
      end
      
      
      if (invalid_cache)
        #Resetting the list
        @all_servers=Hash.new
        PROVIDER.servers.each do |server|
          if !(server.state == "terminated")
            @all_servers[server.tags["Name"]]=server.id	
          else
            @logger.debug "ignoring #{server.id} is terminated"
          end
        end
          dotmccloud=File.new(".mccloud","w")
          dotmccloud.puts(@all_servers.to_json)
          dotmccloud.close
      end
    end
  end
end