module Mccloud
  module Util
    def on_selected_machines(selection)
      if selection.nil? || selection == "all"
        puts "no selection - all machines"
        Mccloud::Config.config.vms.each do |definedvm|
          vm=definedvm[1]
          name=definedvm[0]
          prefix=Mccloud::Config.config.mccloud.prefix
          id=all_servers["#{prefix} - #{name}"]
          vm=Mccloud::Config.config.vms[name]
          yield id,vm

        end
      else
        name=selection
        prefix=Mccloud::Config.config.mccloud.prefix
        id=all_servers["#{prefix} - #{name}"]
        vm=Mccloud::Config.config.vms[name]
        yield id,vm
      end
    end
  end
end