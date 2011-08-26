require 'mccloud/provider/core/vm'

require 'mccloud/provider/vmfusion/vm/up.rb'
#require 'mccloud/provider/vmfusion/vm/bootstrap.rb'
#require 'mccloud/provider/vmfusion/vm/ssh.rb'
#require 'mccloud/provider/vmfusion/vm/scp.rb'
#require 'mccloud/provider/vmfusion/vm/rsync.rb'
require 'mccloud/provider/vmfusion/vm/halt.rb'
require 'mccloud/provider/vmfusion/vm/resume.rb'
require 'mccloud/provider/vmfusion/vm/suspend.rb'
#require 'mccloud/provider/vmfusion/vm/provision.rb'
#require 'mccloud/provider/vmfusion/vm/destroy.rb'


module Mccloud::Provider
  module Vmfusion

      class Vm < ::Mccloud::Provider::Core::Vm
        
        include Mccloud::Provider::Vmfusion::VmCommand
        
        def initialize
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
            if @provider.raw.include?(@name.to_s)
            @raw=Fission::VM.new("#{@name.to_s}")
            end
          end
          
          return @raw
        end      
      end
end
end