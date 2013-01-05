require 'mccloud/provider/core/vm'

require 'mccloud/provider/vagrant/vm/up'
#require 'mccloud/provider/vagrant/vm/bootstrap'
require 'mccloud/provider/vagrant/vm/ssh'
#require 'mccloud/provider/vagrant/vm/scp'
#require 'mccloud/provider/vagrant/vm/rsync'
require 'mccloud/provider/vagrant/vm/reload'
require 'mccloud/provider/vagrant/vm/halt'
require 'mccloud/provider/vagrant/vm/provision'
require 'mccloud/provider/vagrant/vm/destroy'
require 'mccloud/provider/vagrant/vm/forward'

module Mccloud::Provider
  module Vagrant

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Vagrant::VmCommand

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
