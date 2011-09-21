require 'mccloud/provider/core/vm'

require 'mccloud/provider/virtualbox/vm/up'
#require 'mccloud/provider/virtualbox/vm/bootstrap'
require 'mccloud/provider/virtualbox/vm/ssh'
#require 'mccloud/provider/virtualbox/vm/scp'
#require 'mccloud/provider/virtualbox/vm/rsync'
require 'mccloud/provider/virtualbox/vm/halt'
require 'mccloud/provider/virtualbox/vm/provision'
require 'mccloud/provider/virtualbox/vm/destroy'
require 'mccloud/provider/virtualbox/vm/forward'

module Mccloud::Provider
  module Virtualbox

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Virtualbox::VmCommand

      def initialize(env)
        @user="vagrant"
      end

      def ip_address
        "127.0.0.1"
      end

      def public_ip_address
        "127.0.0.1"
      end

      def private_ip_address
        "127.0.0.1"
      end

      def raw
        if @raw.nil?
          @raw=@provider.raw.vms[@name.to_sym]
        end
        return @raw
      end
    end
  end
end
