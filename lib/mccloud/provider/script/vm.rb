require 'mccloud/provider/core/vm'

require 'mccloud/provider/script/vm/up'
require 'mccloud/provider/script/vm/bootstrap'
require 'mccloud/provider/script/vm/ssh'
require 'mccloud/provider/script/vm/scp'
require 'mccloud/provider/script/vm/forward'
require 'mccloud/provider/script/vm/rsync'
require 'mccloud/provider/script/vm/halt'
require 'mccloud/provider/script/vm/provision'
require 'mccloud/provider/script/vm/destroy'

module Mccloud::Provider
  module Script

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Script::VmCommand

      attr_accessor :ip_address
      attr_accessor :variables

    end
  end
end
