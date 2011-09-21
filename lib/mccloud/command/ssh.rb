module Mccloud
  module Command
    class SshCommand < Base

      argument :box_name, :type => :string, :optional => false, :default => nil
      argument :command, :type => :string, :optional => true, :default => nil

      register "ssh [NAME] [COMMAND]", "Ssh-shes into the box"

      def execute
        env.config.providers.each do |name,provider|
          env.logger.debug("Asking provider #{name} to ssh into box #{box_name}")
          provider.ssh(box_name,command,options)
        end
      end
    end
  end
end
