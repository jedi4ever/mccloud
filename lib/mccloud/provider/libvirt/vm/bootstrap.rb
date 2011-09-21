require 'mccloud/util/platform'

module Mccloud::Provider
  module Libvirt
    module VmCommand

      def _bootstrap(command,options=nil)
        if raw.ready?
          env.ui.info "[#{@name}] - Waiting for an ip-address "
          raw.wait_for {   printf "."; STDOUT.flush; !public_ip_address.nil? }
        end
        ssh_bootstrap(command,options)
      end

    end #module
  end #Module
end #module
