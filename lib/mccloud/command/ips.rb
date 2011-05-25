require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    
    def ips(selection, options)
      filter=@session.config.mccloud.stackfilter

      on_selected_ips(selection) do |id,ip|
        ip_instance=ip.instance
        unless ip_instance.nil?
          vm=@session.config.vms[ip.vmname]
          puts "[#{ip.name}] Associating #{ip.address} with #{ip.vmname}"
          ip_instance.server=vm.instance
        else
          puts "[#{ip.name}] Ipaddress does not (yet) exist"
        end
#        ipaddress=ip.instance

#        .each do |member|
#          vm=@session.config.vms[member]
#          server_instance=vm.instance
#          unless server_instance.nil?
#            lb_instance=lb.instance
#            unless lb_instance.nil?
#              puts "[#{lb.name}] Registering #{vm.name} - #{server_instance.id} with loadbalancer "
#              lb_instance.register_instances(server_instance.id)
#            else
#              puts "[#{lb.name} Loadbalancer does not (yet) exist"
#            end
#          else
#            puts "[#{lb.name}] Member #{member} is not yet created. "
#          end
#        end
#      end

    end
    end
 
  end
end
