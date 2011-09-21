require 'mccloud/provider/core/vm'

require 'mccloud/provider/vmfusion/vm/up'
#require 'mccloud/provider/vmfusion/vm/bootstrap'
#require 'mccloud/provider/vmfusion/vm/ssh'
#require 'mccloud/provider/vmfusion/vm/scp'
#require 'mccloud/provider/vmfusion/vm/rsync'
require 'mccloud/provider/vmfusion/vm/halt'
require 'mccloud/provider/vmfusion/vm/resume'
require 'mccloud/provider/vmfusion/vm/suspend'
require 'mccloud/provider/vmfusion/vm/forward'
#require 'mccloud/provider/vmfusion/vm/provision'
#require 'mccloud/provider/vmfusion/vm/destroy'


module Mccloud::Provider
  module Vmfusion

    class Vm < ::Mccloud::Provider::Core::Vm

      include Mccloud::Provider::Vmfusion::VmCommand


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
          if @provider.raw.include?(@name.to_s)
            @raw=Fission::VM.new("#{@name.to_s}")
          end
        end

        return @raw
      end
    end
  end
end
