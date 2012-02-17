module Mccloud
  module Command
    class StatusCommand < Base

      class_option :force, :type => :boolean, :default => false, :aliases => "-f"
      class_option :debug,:type => :boolean , :default => false, :aliases => "-d", :desc => "enable debugging"
      class_option :provider, :type => :string, :optional => true, :default => nil
      argument :name, :type => :string, :optional => true, :default => nil
      register "status [name]", "Shows the status of the current Mccloud environment"

      def execute
        env.load!
        env.config.providers.each do |provider_name,provider_instance|
          provider_instance.status(name,options)
        end
      end
    end
  end
end
