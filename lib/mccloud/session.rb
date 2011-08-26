require 'mccloud/config'

module Mccloud

  class Session
    attr_accessor :config
    attr_accessor :providers
    
    include Mccloud::Logger

    def initialize(options={})
      @config=Config.new.load_mccloud_config({:logger => @logger}.merge(options))
      
      print "Loaded #{@config.providers.length} providers"
      print " #{@config.vms.length} vms"
      print " #{@config.ips.length} ips"
      print " #{@config.stacks.length} stacks"
      puts
    end

    def up(selection,options)
      @config.providers.each do |name,provider|
        provider.up(selection,options)
      end
    end
    
    def boot(selection=nil,options=nil)
      @config.providers.each do |name,provider|
        provider.boot(selection,command,options)
      end
    end

    def bootstrap(selection=nil,options=nil)
      @config.providers.each do |name,provider|
        provider.bootstrap(selection,options)
      end
    end

    def destroy(selection=nil,options=nil)
      @config.providers.each do |name,provider|
        provider.destroy(selection,options)
      end
    end

    def provision(selection=nil,options=nil)
      @config.providers.each do |name,provider|
        provider.provision(selection,options)
      end
    end    

    def ssh(selection,command,options)
      @config.providers.each do |name,provider|
        provider.ssh(selection,command,options)
      end
    end

    def halt(selection,options)
      @config.providers.each do |name,provider|
        provider.halt(selection,options)
      end
    end
    
    def rsync(selection,path,options)
      @config.providers.each do |name,provider|
        provider.rsync(selection,path,options)
      end
    end
    
    def status(selection=nil,options=nil)
      @config.providers.each do |name,provider|
        provider.status(selection,options)
      end
    end #def
    
  end
end
