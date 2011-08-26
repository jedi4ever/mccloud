module Mccloud::Provider
  module Vmfusion
    module VmCommand

        def halt(command,options={})
            raw.stop
        end
 
    end #module
  end #module
end #module
