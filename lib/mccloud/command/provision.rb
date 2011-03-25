require 'net/scp'

module Mccloud
  module Command

    def provision(selection=nil)
      load_config
      on_selected_machines(selection) do |id,vm|
        instance=PROVIDER.servers.get(id)
        instance.private_key_path=vm.key
        instance.username = vm.user
        json=Mccloud::Config.config.chef.setup_json
        cooks=Array.new
        Mccloud::Config.config.chef.cookbooks_path.each do |cook|
          cooks << File.join("/tmp/"+File.basename(cook))
        end
        cookpath="cookbook_path [\""+cooks.join("\",\"")+"\"]"
        loglevel="loglevel :debug"
        configfile=['file_cache_path "/var/chef-solo"',cookpath,loglevel]
        instance.scp(StringIO.new(json),"/tmp/dna.json")
        instance.scp(StringIO.new(configfile.join("\n")),"/tmp/solo.rb")

        Mccloud::Config.config.chef.cookbooks_path.each do |path|
          Mccloud::Rsync.share(path,vm,instance)
        end
        puts "Running chef-solo"
        options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
        Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"sudo chef-solo -c /tmp/solo.rb -j /tmp/dna.json -l debug")
      end
      ##on_selected_machines(selection) do |id,vm|
      #instance=PROVIDER.servers.get(id)
      #options={ :port => 22, :keys => [ vm.key ], :paranoid => false, :keys_only => true}
      #Mccloud::Ssh.execute(instance.public_ip_address,vm.user,options,"who am i")
      #end
    end
    
  end
end