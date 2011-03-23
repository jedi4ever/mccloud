require 'mccloud/vm'
require 'mccloud/provisioner/chef_solo'

include Mccloud::Provisioner

module Mccloud
  
  class MccloudSettings
    attr_accessor :prefix
  end
  class Configuration
    attr_accessor :vms
    attr_reader :vm
    attr_accessor :chef
    attr_accessor :mccloud

    def initialize
      @vm=Vm.new	
      @vms=Hash.new
      @chef=ChefSolo.new	
      @mccloud=MccloudSettings.new	
    end
  end
  module Config
    class << self; attr_accessor :config end
    def self.run
      @config=Configuration.new
      yield @config
    end
  end
end
