module Mccloud
  module Command
    class LbCommand < Mccloud::Command::GroupBase
      register "lb", "Subcommand to manage Loadbalancers"

      desc "list [LB-NAME]", "List loadbalancers"
      method_options :test => :boolean
      def list(selection=nil)
          env.config.providers.each do |name,provider|
            env.logger.debug("Asking provider #{name} to list lb #{selection}")
            provider.lb_list(selection,options)
          end
      end

      desc "associate [LB-NAME]", "Associate LB addresses"
      def associate(selection=nil)
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to associate lb #{selection}")
          provider.on_selected_components("lb",selection) do |id,lb|
            lb.associate(options)
          end
        end
      end

      desc "sorry [LB-NAME]", "Put loadbalancers in a sorry state"
      def sorry(selection=nil)
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to sorry lb #{selection}")
          provider.on_selected_components("lb",selection) do |id,lb|
            lb.sorry(options)
          end
        end
      end

    end #Class

  end #Module
end # Module
