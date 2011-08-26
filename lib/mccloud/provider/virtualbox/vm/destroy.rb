module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def destroy(command,options={})
            Vagrant::CLI.start(["destroy"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
