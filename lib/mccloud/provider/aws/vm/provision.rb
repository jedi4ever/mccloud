module Mccloud::Provider
  module Aws
    module VmCommand

      def _provision(options)
        unless raw.nil?

          if raw.ready?
            @provisioners.each do |provisioner|
              puts "[#{@name}] - starting provisioning with #{provisioner.name} as provisioner"
              provisioner.run(self)
            end
          else
            puts "[#{@name}] - machine is not running, skipping provisioning"
          end
        else
          puts "[#{@name}] - machine doesn't exit yet"
        end
      end

    end #module
  end #module
end #module
