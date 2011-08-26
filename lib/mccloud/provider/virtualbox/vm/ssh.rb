module Mccloud::Provider
  module Virtualbox
    module VmCommand

        def ssh(command,options={})
             Vagrant::CLI.start(["ssh"],:env => @provider.raw)
        end
 
    end #module
  end #module
end #module
