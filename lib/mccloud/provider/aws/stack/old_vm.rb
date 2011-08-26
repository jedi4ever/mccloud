require 'mccloud/provider/core/vm'

require 'mccloud/provider/aws/vm/up.rb'
require 'mccloud/provider/aws/vm/bootstrap.rb'
require 'mccloud/provider/aws/vm/ssh.rb'
require 'mccloud/provider/aws/vm/scp.rb'
require 'mccloud/provider/aws/vm/rsync.rb'
##require 'mccloud/provider/aws/command/vm/halt.rb'
require 'mccloud/provider/aws/vm/provision.rb'
require 'mccloud/provider/aws/vm/destroy.rb'


module Mccloud::Provider
  module Aws


      class Vm < ::Mccloud::Provider::Core::Vm

        attr_accessor :ami
        attr_accessor :key_name

#        attr_accessor :server_id
        
        include Mccloud::Provider::Aws::VmCommand
              
      end
end
end



#attr_accessor :instance,:vm,:provider

#def initialize(vm,provider)
#  @vm=vm
#  @provider=provider
#  found=@provider.raw_provider.servers.all(:name => @vm.name)
#  unless found.nil?
#    @instance=found.first
#    @instance.private_key_path=@vm.private_key
#    @instance.username = @vm.user
#  end
#end

unless server.state=="terminated"

  full_name="#{server.tags['Name']}"
  if full_name.start_with?(filter)

    temp_name=String.new(full_name)
    temp_name[filter]=""
    short_name=temp_name

    #  if the VM was not declared
    unless !@session.config.vms[short_name].nil?
      #puts "#{short_name} - has been not been declared as a vm"
      undeclared_vm=Mccloud::Type::Vm.new	
      undeclared_vm.declared=false
      undeclared_vm.server_id=server.id
      @session.config.vms[short_name]=undeclared_vm                
    else

    end

    # Set the server.id of the vm
    @session.config.vms[short_name].server_id=server.id
    @session.config.vms[short_name].provider=name

    # Check if the server is part of a stack
    stack_name=server.tags['aws:cloudformation:stack-name']

    unless stack_name.nil?
      filtered_stack_name=stack_name
      filtered_stack_name[stack_filter]=""
      # Lookup stack on our config
      #puts "Note: #{short_name} is part of #{filtered_stack_name} "

      if @session.config.stacks.has_key?(filtered_stack_name)
        # If we found it, set the private, public and user appropriatly
        
        #puts "  [#{short_name}] Adjusting public and private keys for stack"
        @session.config.vms[short_name].private_key=@session.config.stacks[filtered_stack_name].private_key_for_instance(short_name)
        @session.config.vms[short_name].public_key=@session.config.stacks[filtered_stack_name].public_key_for_instance(short_name)
        @session.config.vms[short_name].user=@session.config.stacks[filtered_stack_name].user_for_instance(short_name)

      else
        puts "Stack #{filtered_stack_name} is not defined "

      end



    end


  end
end

