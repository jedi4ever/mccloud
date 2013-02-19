module Mccloud::Provider
  module Vagrant
    module VmCommand

        def ssh(command,options={})
          self.provider.raw.cli(['ssh',self.name, command])
        end

    end #module
  end #module
end #module
