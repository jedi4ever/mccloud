require 'mccloud/provisioner/chef_solo'

require 'mccloud/type/vm'

module Mccloud
  module Configurator
    
  class VmConfigurator
    attr_accessor :ami
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :name
    attr_accessor :user
    attr_accessor :key
    attr_accessor :bootstrap

    attr_accessor :chef
    attr_accessor :vm
    
    def initialize()
      @chef=Mccloud::Provisioner::ChefSolo.new
      @vm=Mccloud::Type::Vm.new	
    end
    
    def define(name)
      vmconfig=self
      yield vmconfig
      @vm.name=name
      Mccloud.session.config.vms[name.to_s]=@vm
    end
    def provision(type)
#      provisioner=@chef
#      yield provisioner
#      Mccloud.session.config.chef=provisioner
    end
    def forward_port(local,remote,host)
    end
  end
  
end
end #Module Mccloud