module Mccloud::Provider
  module Vagrant
    module VmCommand

      def up(command,options={})
        self.provider.raw.cli(['up',name])
      end

    end #module
  end #module
end #module
