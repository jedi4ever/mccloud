require 'mccloud/provider/core/vm'

#require 'mccloud/provider/host/vm/up.rb'
#require 'mccloud/provider/host/vm/bootstrap.rb'
require 'mccloud/provider/host/vm/ssh.rb'
require 'mccloud/provider/host/vm/scp.rb'
#require 'mccloud/provider/host/vm/rsync.rb'
#require 'mccloud/provider/host/vm/halt.rb'
require 'mccloud/provider/host/vm/provision.rb'
#require 'mccloud/provider/host/vm/destroy.rb'


module Mccloud::Provider
  module Host

      class Vm < ::Mccloud::Provider::Core::Vm
        
        include Mccloud::Provider::Host::VmCommand
        
        attr_accessor :ip_address

      end
end
end