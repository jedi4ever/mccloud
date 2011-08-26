module Mccloud::Provider
  module Libvirt
    module VmCommand

        def halt(options)
          
          puts "Halting of libvirt vm #{@name}"

          raw.shutdown()
        end
 
    end #module
  end #module
end #module
