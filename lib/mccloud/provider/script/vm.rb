require 'mccloud/provider/core/vm'

module Mccloud::Provider
  module Script

    class Vm < ::Mccloud::Provider::Core::Vm

      attr_accessor :ip_address
      attr_accessor :variables

    end
  end
end
