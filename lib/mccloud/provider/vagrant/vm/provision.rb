module Mccloud::Provider
  module Vagrant
    module VmCommand

        def _provision(command,options={})
          self.provider.raw.cli(['provision',name])
        end

    end #module
  end #module
end #module
