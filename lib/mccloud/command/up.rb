require 'pp'
require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    def up(selection)
    
    on_selected_machines(selection) do |id,vm|

      provider=@session.config.providers[vm.provider]
      if (id.nil?)
        puts "#{vm.name} doesn't yet exist"
        provider_options=vm.provider_options
        boxname=vm.name
        puts "spinning up a new machine called #{boxname}"
        instance=provider.servers.create(provider_options)
        puts "waiting for it the machine to become accessible"
        instance.wait_for { ready?}
        prefix=@session.config.mccloud.prefix

        provider.create_tags(instance.id, { "Name" => "#{prefix} - #{boxname}"})       
      else 
        state=vm.instance.state
        if state =="stopped"
          puts "machine was stopped -> starting it again"
          vm.instance.start
        else
          puts "Machine #{selection} already exists but is in state #{state} "
        end
      end
    end

    #server.boostrap(:image_id => 'ami', :private_key_path => '', :public_key_path => '')
  end
end
end