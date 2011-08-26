require 'mccloud/provider/core/vm'

require 'mccloud/provider/aws/vm/up.rb'
require 'mccloud/provider/aws/vm/bootstrap.rb'
require 'mccloud/provider/aws/vm/ssh.rb'
require 'mccloud/provider/aws/vm/scp.rb'
require 'mccloud/provider/aws/vm/rsync.rb'
require 'mccloud/provider/aws/vm/halt.rb'
require 'mccloud/provider/aws/vm/provision.rb'
require 'mccloud/provider/aws/vm/destroy.rb'


module Mccloud::Provider
  module Aws

      class Vm < ::Mccloud::Provider::Core::Vm

        attr_accessor :ami
        attr_accessor :key_name
        
        include Mccloud::Provider::Aws::VmCommand
        
        def ip_address
          return self.public_ip_address
        end
        
        def public_ip_address
          unless raw.nil?
            ip=raw.public_ip_address
          else
            ip=nil
          end
          return ip
        end
        
        def private_ip_address
          unless raw.nil?
            ip=raw.private_ip_address
          else
            ip=nil
          end
          return ip
        end
        
        
        def raw
          if @raw.nil?
            rawname="#{@provider.filter}#{@name}"
            @provider.raw.servers.each do |vm|
              name=nil
              name=vm.tags["Name"].strip unless vm.tags["Name"].nil?
              if name==rawname
                @raw=vm
              end
            end
          else
            @raw.private_key_path=@private_key_path
            @raw.username = @user
          end
          
          return @raw
        end
              
      end
end
end
