module Mccloud
  module Command
    class SorryCommand < Base

      register "sorry [LB-NAME]", "Puts loadbalancers in a sorry state"
      argument :selection, :type => :string, :optional => true, :default => nil

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to sorry #{selection}")
          provider.on_selected_components("lb",selection) do |id,lb|
            lb.sorry(options)
          end
        end
      end

    end

  end
end
