module Mccloud::Provider
  module Vagrant
    module VmCommand

        def destroy(command,options={})
          self.provider.raw.cli(['destroy',name])
        end

    end #module
  end #module
end #module
