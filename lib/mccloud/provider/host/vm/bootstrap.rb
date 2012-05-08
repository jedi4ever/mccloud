module Mccloud::Provider
  module Host
    module VmCommand

      def _bootstrap(command,options=nil)
        ssh_bootstrap(command,options)
      end

    end #module
  end #module
end #module
