module Mccloud::Provider
  module Vagrant
    module VmCommand

        def resume(command,options={})
          self.provider.raw.cli(['resume',name])
        end

    end #module
  end #module
end #module
