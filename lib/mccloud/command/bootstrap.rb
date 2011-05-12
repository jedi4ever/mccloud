require 'pp'
module Mccloud
  module Command
    def bootstrap(selection=nil,command="who am i",options=nil)
      
      on_selected_machines(selection) do |id,vm|
        
        puts "#{id}"
        puts "bootstrap #{selection} "
        server=vm.instance
        server.private_key_path=vm.private_key
        server.username = vm.user
        if server.state == "running"
          unless vm.bootstrap.nil?
          puts "Uploading bootstrap code to machine #{vm.name}"
          unless !File.exists?(vm.bootstrap)
            server.scp(vm.bootstrap,"/tmp/bootstrap.sh")
            puts "Enabling the bootstrap code to run"
            result=server.ssh("chmod +x /tmp/bootstrap.sh")
            multi(selection,"/tmp/bootstrap.sh",options.merge({ "sudo" => true}))
            
          else
            puts "Error: bootstrap file #{vm.bootstrap} does not exist"
            exit -1
          end
        else
          puts "You didn't specify a bootstrap, hope you know what you're doing."
          end
        else
          puts "server is not running, so bootstrapping will do no good"
        end
        #instance=PROVIDER.servers.get(id)
        #options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
        #Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"sudo /tmp/bootstrap.sh")



      end
      
    end
  end
end
