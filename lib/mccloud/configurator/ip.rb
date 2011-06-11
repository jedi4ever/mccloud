require 'mccloud/type/ip'

module Mccloud
  module Configurator
    
  class IpConfigurator

    attr_accessor :ip
    
    def initialize()
     end
    
    def define(name)
      @ip=Mccloud::Type::Ip.new	
      ipconfig=self
      yield ipconfig
      @ip.name=name
      Mccloud.session.config.ips[name.to_s]=@ip
    end

  end #Class IPConfigurator
  
end #Module Configurator
end #Module Mccloud
