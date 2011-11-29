module Mccloud
  module Command
    class BalanceCommand < Base

      register "balance [LB-NAME]", "Balances loadbalancers"
      argument :selection, :type => :string, :optional => true, :default => nil

      def execute
        env.load!
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to associate to #{selection}")
          provider.on_selected_components("lb",selection) do |id,lb|
            lb.associate(options)
          end
        end
      end

    end

  end
end
