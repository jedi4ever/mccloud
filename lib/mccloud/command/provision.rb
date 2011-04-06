require 'net/scp'

module Mccloud
  module Command

    def provision(selection=nil,options=nil)
      on_selected_machines(selection) do |id,vm|
        instance=vm.instance
        instance.private_key_path=vm.key
        instance.username = vm.user
  
        #p vm.provisioner
        provisioner=@session.config.provisioners[vm.provisioner.to_s]
        if provisioner.nil?
          # We take the first provisioner defined
          provisioner=@session.config.provisioners.first[1]
        end
        provisioner.run(vm)
      end
      ##on_selected_machines(selection) do |id,vm|
      #instance=PROVIDER.servers.get(id)
      #options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
      #Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"who am i")
      #end
    end
    
  end
end