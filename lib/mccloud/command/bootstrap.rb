module Mccloud
  module Command
    class BootstrapCommand < Base

      argument :box_name, :type => :string, :optional => true, :default => nil
      argument :command, :type => :string, :optional => true, :default => nil

      register "bootstrap [NAME] [FILENAME]", "Executes the bootstrap sequence"

      def execute
        env.load!
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to boostrap box #{box_name}")
          provider.bootstrap(box_name,command,options)
        end
      end
    end
  end
end
