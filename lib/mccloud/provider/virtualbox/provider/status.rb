module Mccloud::Provider
  module Virtualbox
    module ProviderCommand
  
    def status(selection=nil,options=nil)
# => Hm', this seems to fail because it tries to do multi param info, warn statements
#      Vagrant::CLI.start(["status"],:env => raw)
      
    end
    
    end #module  
  end #module
end #module

