require 'pp'
module Mccloud
  module Command
    def self.up(selection)
    
    pp Mccloud.session.config
    exit
    on_selected_machines(selection) do |id,vm|
      if (id.nil?)
        puts "#{vm.name} doesn't yet exist"
        provider_options=vm.provider_options
        boxname=vm.name
        puts "spinning up a new machine called #{boxname}"
        server= PROVIDER.servers.create(provider_options)
        puts "waiting for it the machine to become accessible"
        server.wait_for { ready?}
        prefix=Mccloud::Config.config.mccloud.prefix

        PROVIDER.create_tags(server.id, { "Name" => "#{prefix} - #{boxname}"})       
      else 
        state=PROVIDER.servers.get(id).state
        if state =="stopped"
          puts "machine was stopped -> starting it again"
          PROVIDER.servers.get(id).start
        else
          puts "Machine #{selection} already exists but is in state #{state} "
        end
      end
    end

    #server.boostrap(:image_id => 'ami', :private_key_path => '', :public_key_path => '')
  end
end
end