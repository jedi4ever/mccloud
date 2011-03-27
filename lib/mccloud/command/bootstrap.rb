module Mccloud
  module Command
    def bootstrap(selection=nil,command="who am i",options=nil)
      on_selected_machines(selection) do |id,vm|
        server=vm.instance
        server.private_key_path=vm.key
        server.username = vm.user
        if server.state == "running"
          puts "uploading bootstrap code to machine #{vm.name}"
          server.scp(vm.bootstrap,"/tmp/bootstrap.sh")
          puts "enabling the bootstrap code to run"
          result=server.ssh("chmod +x /tmp/bootstrap.sh")
        else
          puts "server is not running, so bootstrapping will do no good"
        end
        #instance=PROVIDER.servers.get(id)
        #options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
        #Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"sudo /tmp/bootstrap.sh")
      end
      multi(selection,"sudo /tmp/bootstrap.sh",options)
    end
  end
end