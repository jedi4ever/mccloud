module Mccloud
  module Command
    class StatusCommand < Base

      class_option :force, :type => :boolean, :default => false, :aliases => "-f"
      argument :provider, :type => :string, :optional => true, :default => nil
      register "status [PROVIDER]", "Shows the status of the current Mccloud environment"

      def execute

        env.config.providers.each do |name,provider|
          provider.status(provider,options)
        end
      end
    end
  end
end
