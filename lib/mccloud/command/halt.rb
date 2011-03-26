require 'mccloud/util/iterator'

module Mccloud
  module Command
  include Mccloud::Util
  def halt(selection=nil,options=nil)
    on_selected_machines(selection) do |id,vm|
       unless vm.instance.state == "stopping" || vm.instance.state =="stopped"
        puts "halting #{id}"
        vm.instance.stop
      else
        puts "#{server.state} so not halting #{vm.name} - #{id}"        
      end
    end
  end
end
end
