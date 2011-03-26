require 'mccloud/util/iterator'

module Mccloud
  module Command
    def destroy(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        unless vm.instance.state == "shutting-down" || vm.instance.state =="terminated"
          puts "destroying #{id}"
          vm.instance.destroy
        else
          puts "#{vm.instance.state} so not destroying #{vm.name} - #{id}"        
        end
      end
    end
  end
end