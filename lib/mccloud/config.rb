require 'mccloud/configurator/mccloud'
require 'mccloud/configurator/vm'
require 'mccloud/provisioner/chef_solo'

module Mccloud
  
  class Configuration
    attr_accessor :vms
    attr_accessor :providers
    attr_accessor :provisioners
    
    attr_accessor :mccloud
    attr_accessor :vm
    attr_accessor :session
    
    def initialize
      @vms=Hash.new
      @providers=Hash.new
      @vm=Mccloud::Configurator::VmConfigurator.new
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
    end
  end
end
