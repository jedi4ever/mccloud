module Mccloud
  module Command
    class IpsCommand < Base

      register "ips [NAME]", "Associate IP addresses"
      argument :selection, :type => :string, :optional => true, :default => nil

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to associate to #{selection}")
          provider.on_selected_components("ip",selection) do |id,ip|
            ip.associate(options)
          end
        end
      end

    end

  end
end
