require 'pp'
module Mccloud
  module Util
    def on_selected_machines(selection=nil)
      if selection.nil? || selection == "all"
        puts "no selection - all machines"
        @session.config.vms.each do |name,vm|
          id=@all_servers["#{name}"]
          vm=@session.config.vms[name]
          yield id,vm

        end
      else
        name=selection
        id=@all_servers["#{name}"]
        vm=@session.config.vms[name]
        yield id,vm
      end
    end
  end
end