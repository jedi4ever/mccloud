module Mccloud
  module Command
  def reload(selection=nil?)
    load_config
    on_selected_machines(selection) do |id,vm|
      puts "rebooting #{id}"
      PROVIDER.servers.get(id).reboot
    end
  end
end
end
