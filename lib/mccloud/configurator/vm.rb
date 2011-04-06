require 'mccloud/provisioner/chef_solo'
require 'mccloud/provisioner/puppet'

require 'mccloud/type/vm'

module Mccloud
  module Configurator
    
  class VmConfigurator

    attr_accessor :vm
    
    def initialize()
     end
    
    def define(name)
      @vm=Mccloud::Type::Vm.new	
      vmconfig=self
      yield vmconfig
      @vm.name=name
      Mccloud.session.config.vms[name.to_s]=@vm
    end
    def provision(type)
      case type
      when :chef_solo
        @provisioner=Mccloud::Provisioner::ChefSolo.new
      when :puppet
        @provisioner=Mccloud::Provisioner::Puppet.new        
      else
      end
      yield @provisioner
      Mccloud.session.config.provisioners[type.to_s]=@provisioner
    end
  end
  
end
end #Module Mccloud