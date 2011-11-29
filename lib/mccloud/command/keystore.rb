module Mccloud
  module Command
    class KeystoreCommand < Mccloud::Command::GroupBase
      register "keystore", "Subcommand to manage keystores"

      desc "list [KEY-NAME]", "List Keys in Keystore"
      #method_options :test => :boolean
      def list(selection=nil)

          env.config.providers.each do |name,provider|
            env.ui.info("Asking provider #{name} to list keystore #{selection}")
            provider.keystore_list(selection,options)
          end
      end

      desc "sync [KEY-NAME]", "Syncs Local keys with Remote Keystore"
      method_options :overwrite=> :boolean
      def sync(selection=nil)

          env.config.providers.each do |name,provider|
            env.ui.info("Asking provider #{name} to sync keystore #{selection}")
            provider.keystore_sync(selection,options)
          end
      end

    end

  end
end
