require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    def halt(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        unless vm.instance.state == "stopping" || vm.instance.state =="stopped"
          puts "Halting machine #{vm.name}(#{id})"
          vm.instance.stop
          vm.instance.wait_for { printf "."; STDOUT.flush; state=="stopped"}
          puts 
        else
          puts "#{vm.name}(#{id}) is already halted."        
        end
      end
    end
  end
end
