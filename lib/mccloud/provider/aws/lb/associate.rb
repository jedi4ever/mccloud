module Mccloud::Provider
  module Aws
    module LbCommand

      def associate(options)
        balance(@members,options)
      end

      def balance(members,options)
        unless raw.nil?
          current_members=raw.instances
          cleanup_members=current_members
          members.each do |member_id|
            env.logger.info "Attempting to associate  #{@name} with vm name #{member_id}"
            vm=env.config.vms[member_id]
            if vm.nil?
              env.ui.error "vm #{member_id} is not defined"
            else
              if vm.id.nil?
                env.ui.error "vm #{member_id} is not yet instantiated"
              else
                env.logger.info "The loadbalancer currently has members #{current_members.join(",")} associated" unless raw.instances.nil?

                # First add new members
                if current_members.include?(vm.id)
                  cleanup_members=cleanup_members - [ vm.id ]
                  env.ui.info "[#{@name}] Skipping associate #{vm.name} - #{vm.id} as it already is a member"
                else
                  env.ui.info "[#{@name}] Associating #{vm.name} - #{vm.id}"
                  raw.register_instances(vm.id)
                end

              end
            end
          end

          # And now remove old members
          #unless member_ids.include?(instance_id)
          #lb_instance=lb.instance
          require 'pp'
          cleanup_members.each do |member_id|
            env.ui.info "Cleanup of old member #{member_id}"
            raw.deregister_instances(member_id)
          end

        else
          env.ui.error "[#{@name}] Loadbalancer does not (yet) exist"
        end
      end

    end
  end
end
