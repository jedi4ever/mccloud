module Mccloud
  module Command
    class IpCommand < Mccloud::Command::GroupBase
      register "ip", "Subcommand to manage IP's"

      desc "associate [IP-NAME]", "Associate IP addresses"
      def associate(selection=nil)
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to associate to #{selection}")
          provider.on_selected_components("ip",selection) do |id,ip|
            ip.associate(options)
          end
        end
      end

      desc "list [IP-NAME]", "List IP addresses"
      #method_options :test => :boolean
      def list(selection=nil)
          env.config.providers.each do |name,provider|
            env.logger.debug("Asking provider #{name} to list ip #{selection}")
            provider.ip_list(selection,options)
          end
      end

    end

  end
end
