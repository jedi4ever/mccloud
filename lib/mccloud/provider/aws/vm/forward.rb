module Mccloud::Provider
  module Aws
    module VmCommand

        def forward(command,options={})
          @forward_threads=Array.new
          unless raw.nil?
            return self.ssh_forward(options)
          else
            env.ui.info "[#{self.name}] not yet created"
            return [] 
          end
        end

    end #module
  end #module
end #module
