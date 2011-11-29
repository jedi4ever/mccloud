require 'mccloud/util/sshkey'

module Mccloud
  module Command
    class KeypairCommand < Mccloud::Command::GroupBase
      register "keypair", "Subcommand to manage keypairs"

      desc "list", "List defined keypairs"
      #method_options :test => :boolean
      def list(selection=nil)

        env.config.keypairs.each do |name,provider|
          env.ui.info("Keypair name:#{name}")
        end
      end

      desc "generate", "Generate a keypair"
      def generate(name=nil)
        rsa_key=::Mccloud::Util::SSHKey.generate({ :comment => "mykey"})
        env.ui.info rsa_key.ssh_public_key
        env.ui.info rsa_key.rsa_private_key
      end
    end

  end

end
