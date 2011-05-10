require 'pp'
module Mccloud
  module Util
    def on_selected_machines(selection=nil)
      if selection.nil? || selection == "all"
        #puts "no selection - all machines"

        @session.config.vms.each do |name,vm|
          id=@session.config.vms[name].server_id
          vm=@session.config.vms[name]
          yield id,vm
        end
      else
        name=selection
        if @session.config.vms.has_key?(name)
          id=@session.config.vms[name].server_id
          vm=@session.config.vms[name]
          yield id,vm
        end
      end
    end

    def on_selected_stacks(selection=nil)
      if selection.nil? || selection == "all"
        #puts "no selection - all machines"
        @session.config.stacks.each do |name,stack|
          #Would this be StackId?
          id=-1
          stack=@session.config.stacks[name]
            yield id,stack
        end
      else
        name=selection

        #Would this be StackId?
        if @session.config.stacks.has_key?(name)
          id=-1
          stack=@session.config.stacks[name]
          yield id,stack
        end
      end
    end



  end
end