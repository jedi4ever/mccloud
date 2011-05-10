require 'pp'
require 'mccloud/util/iterator'

module Mccloud
  module Command
    include Mccloud::Util
    
    def up(selection,options)
      filter=@session.config.mccloud.stackfilter
      
      
      # http://allanfeid.com/content/using-amazons-cloudformation-cloud-init-chef-and-fog-automate-infrastructure
      on_selected_stacks(selection) do |id,stack|
        stack_fullname="#{filter}#{stack.name}"
        stack_params=stack.params
        template_body=stack.json_rewrite
        
        provider=@session.config.providers[stack.provider]
        unless (stack.exists?)            
          cf = Fog::AWS::CloudFormation.new(stack.provider_options)
          pp stack.provider_options
          pp cf

          begin
            cf.validate_template({'TemplateBody' => template_body})
          rescue  Excon::Errors::BadRequest => e
            puts "Error validating template #{stack.jsonfile}:\n #{e.response.body}"
          end  

          begin
            cf.get_template("#{stack_fullname}")
            #cf.describe_stacks.get(stack_name)
          rescue  Excon::Errors::BadRequest => e
            puts "Error getting the remote template:\n #{e.response.body}"
          end  

          
                    
          begin
            cf.describe_stacks.body["Stacks"].each do |stack|
              pp stack
            end
          rescue  Excon::Errors::BadRequest => e
            puts "Error fetching the stacks:\n #{e.response.body}"
          end  
 

          #DisableRollback, TemplateURL, TimeoutInMinutes

          begin
            pp template_body
            
            cf.create_stack(stack_fullname, {'TemplateBody' => template_body, 'Parameters' => stack_params})
          rescue Excon::Errors::BadRequest => e
            puts "Error creating the stack:\n #{e.response.body}"

            #lets try to remove it
            begin
              sleep 5
              puts "Trying delete_stack"
              cf.delete_stack(stack_fullname)
            rescue Excon::Errors::BadRequest => e
              puts "Error deleting the stacks:\n #{e.response.body}"
            end
            #Throttling
            sleep 5
            
           puts "New creation"           
           
           #cf.create_stack(stack_fullname,{'TemplateBody' => template_body, 'Parameters' => stack_params})

 
          end
          #exit
          
        end
        
      end

      #only do stacks for now
      
      on_selected_machines(selection) do |id,vm|

        # We need to get the correct provider  + region
        
        provider=@session.config.providers[vm.provider+"-"+vm.provider_options[:region]]
        if (id.nil?)
          create_options=vm.create_options
          boxname=vm.name
          puts "Spinning up a new machine called #{boxname}"
          
          create_options=create_options.merge({ :private_key_path => vm.private_key , :public_key_path => vm.public_key, :username => vm.user})
          
          #instance=provider.servers.bootstrap(create_options)

          instance=provider.servers.create(create_options)
          
          puts "Waiting for the machine to become accessible"
          instance.wait_for { printf "."; STDOUT.flush;  ready?}
          puts
          filter=@session.config.mccloud.filter
    
          provider.create_tags(instance.id, { "Name" => "#{filter}#{boxname}"})

          # Resetting the in memory model of the new machine
          @session.config.vms[boxname.to_s].server_id=instance.id
          @session.config.vms[boxname.to_s].provider=@session.config.vms[boxname.to_s].provider+"-"+@session.config.vms[boxname.to_s].provider_options[:region]
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
            puts "[#{vm.name}] - already running."
          end
        end

        @session.provision(boxname.to_s,options) 
      end

            

    end
 
 
 
 
 
  end
end