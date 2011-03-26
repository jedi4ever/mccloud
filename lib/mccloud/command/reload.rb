module Mccloud
  module Command
  def reload(selection=nil?)
    load_config
    on_selected_machines(selection) do |id,vm|
      puts "rebooting #{id}"
      vm.instance.reboot
    end
  end
end
end
