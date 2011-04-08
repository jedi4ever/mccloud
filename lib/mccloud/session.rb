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
require 'mccloud/command/reload'
require 'mccloud/command/multi'
require 'mccloud/command/init'
require 'mccloud/command/suspend'
require 'mccloud/command/destroy'
require 'mccloud/command/provision'
require 'mccloud/command/server'

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
      @logger.level = Logger::INFO

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
        if @session.config.providers[vm.provider].nil?
        
        @logger.debug "adding provider #{vm.provider}"
        begin
          @session.config.providers[vm.provider]=Fog::Compute.new(:provider => vm.provider)
        rescue ArgumentError => e
          #  Missing required arguments: 
          required_string=e.message
          required_string["Missing required arguments: "]=""
          required_options=required_string.split(", ")
          puts "Please provide credentials for provider [#{vm.provider}]:"
          answer=Hash.new
          for fog_option in required_options do 
            answer["#{fog_option}".to_sym]=ask("- #{fog_option}: ") 
            #{ |q| q.validate = /\A\d{5}(?:-?\d{4})?\Z/ }
          end
          puts "\nThe following snippet will be written to #{File.join(ENV['HOME'],".fog")}"

          snippet=":default:\n"
          for fog_option in required_options do
            snippet=snippet+"  :#{fog_option}: #{answer[fog_option.to_sym]}\n"
          end

          puts "======== snippit start ====="
          puts "#{snippet}"
          puts "======== snippit end ======="
          confirmed=agree("Do you wan to save this?: ")

          if (confirmed)
            fogfilename="#{File.join(ENV['HOME'],".fog")}"
            fogfile=File.new(fogfilename,"w")
            fogfile.puts "#{snippet}"
            fogfile.close
            FileUtils.chmod(0600,fogfilename)
          else
            puts "Ok, we won't write it, but we continue with your credentials in memory"
            exit -1
          end
          begin
            answer[:provider]= vm.provider
            @session.config.providers[vm.provider]=Fog::Compute.new(answer)
          rescue
              puts "We tried to create the provider but failed again, sorry we give up"
              exit -1
          end
        end
   
   
   
   
   
      end
      end

      invalid_cache=false
      @session.config.vms.each do |name,vm|
        filter=@session.config.mccloud.filter
        id=@all_servers["#{name.to_s}"]

        #Check if not destroyed or something else
        instance=vm.instance
        if instance.nil?
          @logger.debug "Cache is invalid"
          invalid_cache=true
        else  
          if instance.state == "shutting-down" || instance.state == "terminated"
            @logger.debug "parsing .mccloud json" 
            @logger.debug "rebuilding cache"
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
        filter=@session.config.mccloud.filter

        @session.config.vms.each do |name,vm|
          id=servers_by_provider[vm.provider]["#{filter} - #{name.to_s}"]


          if !id.nil?
            @all_servers[name]=id
            #@session.config.vms[name].instance=@session.config.providers[vm.provider].servers.get(id)
          end
        end

        #dotmccloud=File.new(".mccloud","w")
        #dotmccloud.puts(@all_servers.to_json)
        #dotmccloud.close


      end
    end




  end
end
