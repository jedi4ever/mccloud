module Mccloud
  module Command
    class PackageCommand < Base

      argument :box_name, :type => :string, :optional => false, :default => nil

      register "package [NAME]", "Packages the machine"

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to package box #{box_name}")
          provider.package(box_name,options)
        end
      end
    end
  end
end
