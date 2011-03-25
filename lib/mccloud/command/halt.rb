module Mccloud
  module Command
  def halt(selection=nil)
    load_config
    on_selected_machines(selection) do |id,vm|
      server=PROVIDER.servers.get(id)
      unless server.state == "stopping" || server.state =="stopped"
        puts "halting #{id}"
        server.stop
      else
        puts "#{server.state} so not halting #{vm.name} - #{id}"        
      end
    end
  end
end
end
