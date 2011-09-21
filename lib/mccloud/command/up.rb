module Mccloud
  module Command
    class UpCommand < Base

      argument :box_name, :type => :string, :optional => true, :default => nil

      register "up [NAME]", "Starts the machine and provisions it"

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to up box #{box_name}")
          provider.up(box_name,options)
        end
      end
    end
  end
end
