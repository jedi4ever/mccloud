module Mccloud::Provider
  module Aws
    module IpCommand

      def associate(options)
        unless raw.nil?
          env.ui.info "[#{@name}] Attempting to associate ip #{@name} with vm name #{@vmname}"
          vm=env.config.vms[@vmname]
          if vm.nil?
            env.ui.error "[#{@name}] vm #{@vmname} is not defined"
            return
          else
            if vm.id.nil?
              env.ui.error "[#{@name}] vm #{@vmname} is not yet instantiated"
              return
            else
              env.ui.info "[#{@name}] The ipaddress currently has server_id #{raw.server_id} associated" unless raw.server_id.nil?
              if raw.server_id==vm.id
                env.ui.info "[#{@name}] #{@address} is already associated with #{@vmname} #{vm.id}"
              else
                env.ui.info "[#{@name}] Associating #{@address} with #{@vmname} #{vm.id}"
                raw.server=vm.raw
              end
            end
          end
        else
          env.ui.error "[#{ip.name}] Ipaddress does not (yet) exist"
        end
      end

    end
  end
end
