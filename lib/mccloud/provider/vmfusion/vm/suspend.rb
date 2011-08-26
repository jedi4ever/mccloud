module Mccloud::Provider
  module Vmfusion
    module VmCommand

        def suspend(command,options={})
            raw.suspend
        end
 
    end #module
  end #module
end #module