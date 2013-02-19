module Mccloud::Provider
  module Vagrant
    module VmCommand

        def suspend(command,options={})
          self.provider.raw.cli(['suspend',name])
        end

    end #module
  end #module
end #module
