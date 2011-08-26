module Mccloud::Provider
  module Aws
    module VmCommand

        def halt(options)

          unless raw.state == "stopping" || raw.state =="stopped"
            puts "Halting machine #{@name}(#{@raw.id})"
            raw.stop
            raw.wait_for { printf "."; STDOUT.flush; state=="stopped"}
            puts 
          else
            puts "#{@name}(#{raw.id}) is already halted."        
          end
                    
        end
 
    end #module
  end #module
end #module


