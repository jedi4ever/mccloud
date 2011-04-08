require 'mccloud/util/iterator'

module Mccloud
  module Command
    def destroy(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        unless vm.instance.nil? || vm.instance.state == "shutting-down" || vm.instance.state =="terminated"
          puts "Destroying machine #{vm.name} (#{id})"
          vm.instance.destroy
          
          vm.instance.wait_for {  print "."; STDOUT.flush; state=="terminated"}
          puts
        else
          puts "Machine #{vm.name} is already terminated"        
        end
      end
    end
  end
end