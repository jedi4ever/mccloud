module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def _provision(command,options={})
            Vagrant::CLI.start(["provision"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
