require 'mccloud/configurator/mccloud'
require 'mccloud/configurator/vm'
require 'mccloud/configurator/lb'
require 'mccloud/configurator/ip'
require 'mccloud/configurator/stack'

module Mccloud
  
  class Configuration
    attr_accessor :vms
    attr_accessor :lbs
    attr_accessor :stacks
    attr_accessor :ips
    attr_accessor :providers
    attr_accessor :provisioners
    
    attr_accessor :mccloud
    attr_accessor :vm
    attr_accessor :stack
    attr_accessor :lb
    attr_accessor :ip
    attr_accessor :session
    
    def initialize
      @vms=Hash.new
      @lbs=Hash.new
      @ips=Hash.new
      
      @stacks=Hash.new
      @providers=Hash.new
      
      @vm=Mccloud::Configurator::VmConfigurator.new
      @lb=Mccloud::Configurator::LbConfigurator.new
      @ip=Mccloud::Configurator::IpConfigurator.new

      @stack=Mccloud::Configurator::StackConfigurator.new
      @mccloud=Mccloud::Configurator::MccloudConfigurator.new	
      @provisioners=Hash.new
    end
  end
  
  module Config
    class << self; 
      attr_accessor :config
    end
    def self.run
      @config=Configuration.new
      
      # Here we access a global thing, TODO to make it session specific
      
      Mccloud.session.config=@config
      yield @config
      #Resetting any left over
      
      @config.vm=nil
      @config.lb=nil
      @config.ip=nil
      @config.stack=nil
    end
  end
end
