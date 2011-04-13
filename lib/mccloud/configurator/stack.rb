require 'mccloud/provisioner/chef_solo'
require 'mccloud/provisioner/puppet'

require 'mccloud/type/stack'

module Mccloud
  module Configurator
    
  class StackConfigurator

    attr_accessor :stack
    
    def initialize()
     end
    
    def define(name)
      @stack=Mccloud::Type::Stack.new	
      stackconfig=self
      yield stackconfig
      @stack.name=name
      Mccloud.session.config.stacks[name.to_s]=@stack
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