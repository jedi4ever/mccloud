require 'mccloud/type/forwarding'
module Mccloud
  module Type
    
  class Vm
    attr_accessor :ami
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :name
    attr_accessor :user
    attr_accessor :key
    attr_accessor :bootstrap
    attr_accessor :provisioner
    attr_accessor :forwardings
    
    attr_accessor :instance
    
    def initialize
      @forwardings=Array.new
    end
    
    def instance
      if @this_instance.nil?
        @this_instance=Mccloud.session.config.providers[provider].servers.get(Mccloud.session.all_servers[name.to_s])
      end
      return @this_instance
    end
    
    def forward_port(name,local,remote)
      forwarding=Forwarding.new(name,local,remote)
      forwardings << forwarding
    end
  end
  
end
end #Module Mccloud