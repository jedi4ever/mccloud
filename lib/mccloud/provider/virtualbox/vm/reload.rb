module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def reload(command,options={})
            Vagrant::CLI.start(["reload"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
