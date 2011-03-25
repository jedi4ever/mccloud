module Mccloud
  module Command
    def suspend
      load_config
      on_selected_machines(selection) do |id,vm|
        puts "halting #{id}"
        PROVIDER.servers.get(id).stop
      end
    end
  end
end