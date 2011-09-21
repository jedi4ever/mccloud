module Mccloud
  module Command
    class ProvisionCommand < Base

      argument :box_name, :type => :string, :optional => false, :default => nil

      register "provision [NAME]", "Provisions the machine"

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to provision box #{box_name}")
          provider.provision(box_name,options)
        end
      end
    end
  end
end
