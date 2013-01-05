module Mccloud::Provider
  module Vagrant
    module VmCommand

        def reload(command,options={})
            self.provider.raw.cli(['reload',name])
        end

    end #module
  end #module
end #module
