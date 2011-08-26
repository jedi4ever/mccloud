require 'mccloud/provider/core/vm'

require 'mccloud/provider/virtualbox/vm/up.rb'
#require 'mccloud/provider/virtualbox/vm/bootstrap.rb'
require 'mccloud/provider/virtualbox/vm/ssh.rb'
#require 'mccloud/provider/virtualbox/vm/scp.rb'
#require 'mccloud/provider/virtualbox/vm/rsync.rb'
require 'mccloud/provider/virtualbox/vm/halt.rb'
require 'mccloud/provider/virtualbox/vm/provision.rb'
require 'mccloud/provider/virtualbox/vm/destroy.rb'


module Mccloud::Provider
  module Virtualbox

      class Vm < ::Mccloud::Provider::Core::Vm
        
        include Mccloud::Provider::Virtualbox::VmCommand
        
        def initialize
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