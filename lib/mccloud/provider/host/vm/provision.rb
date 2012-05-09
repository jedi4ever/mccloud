module Mccloud::Provider
  module Host
    module VmCommand

      def _provision(options)

        self.share

        unless @provisioners.nil?
          @provisioners.each do |provisioner|
            env.ui.info "[#{@name}] - starting provisioning with #{provisioner.name} as provisioner"
            provisioner.run(self)
          end
        end
      end

    end #module
  end #module
end #module
