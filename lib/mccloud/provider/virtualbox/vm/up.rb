module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def up(command,options={})
            Vagrant::CLI.start(["up"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
