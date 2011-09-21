module Mccloud
  module Command
    class ReloadCommand < Base

      argument :box_name, :type => :string, :optional => true, :default => nil

      register "reload [NAME]", "Reboots the machine"

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to reload box #{box_name}")
          provider.reload(box_name,options)
        end
      end
    end
  end
end
