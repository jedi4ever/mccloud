module Mccloud::Provider
  module Vmfusion
    module VmCommand

      def up(command,options={})
        raw.start
      end

    end #module
  end #module
end #module
