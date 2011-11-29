module Mccloud
  module Command
    class HaltCommand < Base

      argument :box_name, :type => :string, :optional => true, :default => nil

      register "halt [NAME]", "Shutdown the machine"
      def execute
        env.load!
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to halt box #{box_name}")
          provider.halt(box_name,options)
        end
      end
    end
  end
end
