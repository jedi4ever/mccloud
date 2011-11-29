module Mccloud
  module Command
    class KeystoreCommand < Mccloud::Command::GroupBase
      register "keystore", "Subcommand to manage keystores"

      desc "list [IP-NAME]", "List Keys in Keystore"
      #method_options :test => :boolean
      def list(selection=nil)

          env.config.providers.each do |name,provider|
            env.ui.info("Asking provider #{name} to list keystore #{selection}")
            provider.keystore_list(selection,options)
          end
      end

    end

  end
end
