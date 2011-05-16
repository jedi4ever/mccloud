require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    
    def loadbalance(selection, options)
      filter=@session.config.mccloud.stackfilter
      
      puts
      on_selected_lbs(selection) do |id,lb|
        lb.members.each do |member|
          vm=@session.config.vms[member]
          server_instance=vm.instance
          unless server_instance.nil?
            lb_instance=lb.instance
            unless lb_instance.nil?
              puts "[#{lb.name}] Registering #{vm.name} - #{server_instance.id} with loadbalancer "
              lb_instance.register_instances(server_instance.id)
            else
              puts "[#{lb.name} Loadbalancer does not (yet) exist"
            end
          else
            puts "[#{lb.name}] Member #{member} is not yet created. "
          end
        end
      end

    end
 
  end
end
