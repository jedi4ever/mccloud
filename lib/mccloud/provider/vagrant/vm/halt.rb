module Mccloud::Provider
  module Vagrant
    module VmCommand

        def halt(command,options={})
            self.provider.raw.cli(['halt',name])
        end

    end #module
  end #module
end #module
