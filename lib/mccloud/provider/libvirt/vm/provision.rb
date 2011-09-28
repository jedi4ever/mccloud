module Mccloud::Provider
  module Libvirt
    module VmCommand

      def _provision(options)

        unless raw.nil?

          if raw.ready?
            @provisioners.each do |provisioner|
              env.ui.info "[#{@name}] - starting provisioning with #{provisioner.name} as provisioner"
              provisioner.run(self)
            end
          else
            env.ui.info "[#{@name}] - machine is not running, skipping provisioning"
          end
        else
          env.ui.info "[#{@name}] - machine doesn't exit yet"
        end

      end

    end #module
  end #module
end #module
