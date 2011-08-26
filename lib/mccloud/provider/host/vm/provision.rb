module Mccloud::Provider
  module Host
    module VmCommand

        def _provision(options)
              unless @provisioners.nil?
                  @provisioners.each do |provisioner|
                    puts "[#{@name}] - starting provisioning with #{provisioner.name} as provisioner"
                    provisioner.run(self)
                  end
                end
        end
 
    end #module
  end #module
end #module
