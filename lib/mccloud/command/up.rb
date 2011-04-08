require 'pp'
require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    def up(selection,options)

      on_selected_machines(selection) do |id,vm|

        provider=@session.config.providers[vm.provider]
        if (id.nil?)
          provider_options=vm.provider_options
          boxname=vm.name
          puts "Spinning up a new machine called #{boxname}"
          
          provider_options=provider_options.merge({ :private_key_path => vm.private_key , :public_key_path => vm.public_key, :username => vm.user})
          
          #instance=provider.servers.bootstrap(provider_options)

          instance=provider.servers.create(provider_options)
          #instance=provider.servers.create(provider_options)
          
          puts "Waiting for the machine to become accessible"
          instance.wait_for { printf "."; STDOUT.flush;  ready?}
          puts
          filter=@session.config.mccloud.filter
    
          provider.create_tags(instance.id, { "Name" => "#{filter} - #{boxname}"})

          # Resetting the in memory model of the new machine
          @all_servers[boxname.to_s]=instance.id
          unless @session.config.vms[boxname.to_s].nil?
            @session.config.vms[boxname.to_s].reload
          end

          # Wait for ssh to become available ...
          puts "Waiting for ssh to be come available"
          #puts instance.console_output.body["output"]

          Mccloud::Util.execute_when_tcp_available(instance.public_ip_address, { :port => 22, :timeout => 60 }) do
            puts "Ok, ssh is available , proceeding with bootstrap"
          end

          @session.bootstrap(boxname.to_s,nil,options)       

        else 
          state=vm.instance.state
          if state =="stopped"
            puts "Booting up machine #{vm.name}"
            vm.instance.start
            vm.instance.wait_for { printf ".";STDOUT.flush;  ready?}  
            puts        
          else
            puts "Machine #{selection} is already running."
          end
        end


      end

      @session.provision(selection,options)       

    end
 
 
 
 
 
  end
end