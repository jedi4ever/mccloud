require 'net/scp'

module Mccloud
  module Command

    def provision(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        
        
        instance=vm.instance
        
        unless instance.nil?
        instance.private_key_path=vm.private_key
        instance.username = vm.user
  
          if instance.state=="running"
            #p vm.provisioner
            provisioner=vm.provisioner
            if provisioner.nil?
              # We take the first provisioner defined
              #provisioner=@session.config.provisioners.first[1]
            else
              puts "[#{vm.name}] - starting provisioning with #{vm.provisioner} as provisioner"
              provisioner.run(vm)
            end
        else
          puts "[#{vm.name}] machine is not running, skipping provisioning"
        end
      else
        puts "[#{vm.name}] machine doesn't exit yet"
      end
      end
      ##on_selected_machines(selection) do |id,vm|
      #instance=PROVIDER.servers.get(id)
      #options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
      #Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"who am i")
      #end
    end
    
  end
end