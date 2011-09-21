module Mccloud::Provider
  module Vmfusion
    module VmCommand

        def forward(command,options={})
          @forward_threads=Array.new
          return self.ssh_forward(options)
        end

    end #module
  end #module
end #module
