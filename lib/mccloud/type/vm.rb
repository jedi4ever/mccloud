require 'pp'
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
    #attr_accessor :instance
    
    def instance
      this_instance=Mccloud.session.config.providers[provider].servers.get(Mccloud.session.all_servers[name.to_s])
      return this_instance
    end
    
    def forward_port(local,remote,host)
    end
  end
  
end
end #Module Mccloud