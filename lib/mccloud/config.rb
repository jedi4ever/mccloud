require 'mccloud/configurator/mccloud'
require 'mccloud/configurator/vm'
require 'mccloud/provisioner/chef_solo'

module Mccloud
  
  class Configuration
    attr_accessor :vms

    attr_accessor :mccloud
    attr_accessor :vm
    
    def initialize
      @vms=Hash.new
      @vm=Mccloud::Configurator::VmConfigurator.new
      @mccloud=Mccloud::Configurator::MccloudConfigurator.new	
    end
  end
  
  module Config
    class << self; attr_accessor :config end
    def self.run
      @config=Configuration.new
      Mccloud.session.config=@config
      yield @config
    end
  end
end
