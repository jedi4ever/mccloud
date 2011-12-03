module Mccloud::Provider
  module Aws
    module VmCommand

      def _provision(options=nil)
        unless raw.nil?

          if raw.ready?
            @provisioners.each do |provisioner|
              env.ui.info "[#{@name}] - starting provisioning with #{provisioner.name} as provisioner"
              provisioner.run(self)
            end
          else
            raise Mccloud::Error, "[#{@name}] - machine is not running, skipping provisioning"
          end
        else
          raise Mccloud::Error, "[#{@name}] - machine doesn't exit yet"
        end
      end

    end #module
  end #module
end #module
