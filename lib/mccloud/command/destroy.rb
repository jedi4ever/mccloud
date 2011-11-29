module Mccloud
  module Command
    class DestroyCommand < Base

      argument :box_name, :type => :string, :optional => false, :default => nil

      register "destroy [NAME]", "Destroys the machine"

      def execute
        env.load!
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to destroy box #{box_name}")
          provider.destroy(box_name,options)
        end
      end
    end
  end
end
