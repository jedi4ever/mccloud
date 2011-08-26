require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util

    def sorry(selection, options)
      filter=@session.config.mccloud.stackfilter

      puts
      on_selected_lbs(selection) do |id,lb|

        if lb.sorry_members.nil?
          puts "[#{lb.name}] has no sorry_members defined, skipping"
        else
          member_ids=Array.new
          lb_instance=lb.instance
          #Adding new member first
          lb.sorry_members.each do |member|
            vm=@session.config.vms[member]
            server_instance=vm.instance
            unless server_instance.nil?
              unless lb_instance.nil?
                puts "[#{lb.name}] Registering #{vm.name} - #{server_instance.id} with loadbalancer "
                lb_instance.register_instances(server_instance.id)
                member_ids << server_instance.id
              else
                puts "[#{lb.name} Loadbalancer does not (yet) exist"
              end
            else
              puts "[#{lb.name}] Member #{member} is not yet created. "
            end
          end

          #Removing old members
          lb_instance.instances.each do |instance_id|
            unless member_ids.include?(instance_id)
              lb_instance=lb.instance
              lb_instance.deregister_instances(instance_id)
              puts "[#{lb.name}] De-registering member #{instance_id} with loadbalancer "

            end
          end
        end

      end

    end

  end
end
