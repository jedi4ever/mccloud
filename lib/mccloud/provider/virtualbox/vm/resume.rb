module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def resume(command,options={})
            Vagrant::CLI.start(["resume"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
