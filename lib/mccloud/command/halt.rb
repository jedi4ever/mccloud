require 'mccloud/util/iterator'

module Mccloud
  module Command
  include Mccloud::Util
  def halt(selection=nil,options=nil)
    on_selected_machines(selection) do |id,vm|
       unless vm.instance.state == "stopping" || vm.instance.state =="stopped"
        puts "halting #{id}"
        vm.instance.stop
        vm.instance.wait_for { printf "."; STDOUT.flush; state=="stopped"}
        puts 
      else
        puts "#{vm.name} has state: #{server.state} so we're not halting #{vm.name} - #{id}"        
      end
    end
  end
end
end
