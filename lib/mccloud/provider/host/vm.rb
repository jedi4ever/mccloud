require 'mccloud/provider/core/vm'

#require 'mccloud/provider/host/vm/up'
#require 'mccloud/provider/host/vm/bootstrap'
require 'mccloud/provider/host/vm/ssh'
require 'mccloud/provider/host/vm/scp'
require 'mccloud/provider/host/vm/forward'
#require 'mccloud/provider/host/vm/rsync'
#require 'mccloud/provider/host/vm/halt'
require 'mccloud/provider/host/vm/provision'
#require 'mccloud/provider/host/vm/destroy'

module Mccloud::Provider
  module Host

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Host::VmCommand

      attr_accessor :ip_address

    end
  end
end
