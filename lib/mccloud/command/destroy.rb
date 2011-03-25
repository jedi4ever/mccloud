module Mccloud
  module Command
    load_config
    on_selected_machines(selection) do |id,vm|
      server=PROVIDER.servers.get(id)
      unless server.state == "shutting-down" || server.state =="terminated"
        puts "destroying #{id}"
        server.destroy
      else
        puts "#{server.state} so not destroying #{vm.name} - #{id}"        
      end
    end
  end
end
