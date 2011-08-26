module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def halt(command,options={})
            Vagrant::CLI.start(["halt"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
