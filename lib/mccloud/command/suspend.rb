module Mccloud
  module Command
    def suspend
      load_config
      on_selected_machines(selection) do |id,vm|
        puts "Halting machine #{vm.name} with Id: #{id}"
        PROVIDER.servers.get(id).stop

        vm.instance.wait_for { printf ".";STDOUT.flush;  state=="stopped"}          
        puts
        
      end
    end
  end
end