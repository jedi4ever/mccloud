require 'mccloud/util/platform'

module Mccloud::Provider
  module Aws
    module VmCommand

      def _bootstrap(command,options=nil)
         ssh_bootstrap(command,options)
      end

    end #module
  end #Module
end #module
