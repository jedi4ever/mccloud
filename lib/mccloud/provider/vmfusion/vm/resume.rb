module Mccloud::Provider
  module Vmfusion
    module VmCommand

        def resume(command,options={})
            raw.start
        end
 
    end #module
  end #module
end #module
