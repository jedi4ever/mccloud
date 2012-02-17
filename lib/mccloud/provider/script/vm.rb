require 'mccloud/provider/core/vm'

require 'mccloud/provider/script/vm/status'

module Mccloud::Provider
  module Script

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Script::VmCommand

      attr_accessor :ip_address
      attr_accessor :variables

    end
  end
end
