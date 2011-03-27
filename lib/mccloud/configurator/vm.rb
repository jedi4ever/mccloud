require 'mccloud/provisioner/chef_solo'
require 'mccloud/provisioner/puppet'

require 'mccloud/type/vm'

module Mccloud
  module Configurator
    
  class VmConfigurator
#    attr_accessor :ami
#    attr_accessor :provider
#    attr_accessor :provider_options
#    attr_accessor :name
#    attr_accessor :user
#    attr_accessor :key
#    attr_accessor :bootstrap

#    attr_accessor :chef
    attr_accessor :vm
    
    def initialize()
#      @chef=Mccloud::Provisioner::ChefSolo.new
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
#      Mccloud.session.config.chef=provisioner
    end
#    def forward_port(local,remote,host)
#      @vm.forward_port(local,remote,host)
#    end
  end
  
end
end #Module Mccloud