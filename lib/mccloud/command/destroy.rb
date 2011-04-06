require 'mccloud/util/iterator'

module Mccloud
  module Command
    def destroy(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        unless vm.instance.state == "shutting-down" || vm.instance.state =="terminated"
          puts "Destroying #{vm.name} with id - #{id}"
          vm.instance.destroy
          
          vm.instance.wait_for {  print "."; STDOUT.flush; state=="terminated"}
          puts
        else
          puts "Server #{vm.name} - Id: #{id} has state #{vm.instance.state} so not destroying it "        
        end
      end
    end
  end
end