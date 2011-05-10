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

  end
  
end
end #Module Mccloud