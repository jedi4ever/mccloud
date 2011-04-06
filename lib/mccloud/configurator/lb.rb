require 'mccloud/provisioner/chef_solo'
require 'mccloud/provisioner/puppet'

require 'mccloud/type/lb'

module Mccloud
  module Configurator
    
  class LbConfigurator

    attr_accessor :lb
    
    def initialize()
     end
    
    def define(name)
      @lb=Mccloud::Type::Lb.new	
      lbconfig=self
      yield lbconfig
      @lb.name=name
      Mccloud.session.config.lbs[name.to_s]=@lb
    end
  end
  
end
end #Module Mccloud