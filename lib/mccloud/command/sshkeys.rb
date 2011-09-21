require 'mccloud/util/sshkey'

module Mccloud
  module Command
    class SshkeysCommand < Base
      include Mccloud::Util

      register "sshkeys","generates sshkeys if none exist"
      def execute
        rsa_key=SSHKey.generate({ :comment => "mykey"})
        puts rsa_key.ssh_public_key
        puts rsa_key.rsa_private_key
      end
    end #Class
  end #Module
end #Module
