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

          begin
            cf.validate_template({'TemplateBody' => template_body})
          rescue  Excon::Errors::BadRequest => e
            puts "[#{stack.name}] - Error validating template #{stack.jsonfile}:\n #{e.response.body}"
          end  

          template_exists=false
          begin
            cf.get_template("#{stack_fullname}")
            template_exists=true
          rescue  Excon::Errors::BadRequest => e
            #            puts "[#{stack.name}] - Error getting the remote template:\n #{e.response.body}"
          end  

          unless template_exists
            #DisableRollback, TemplateURL, TimeoutInMinutes
            begin
              cf.create_stack(stack_fullname, {'TemplateBody' => template_body, 'Parameters' => stack_params})
              puts "[#{stack.name}] - Stack creation started"           
            rescue Excon::Errors::BadRequest => e
              puts "[#{stack.name}] - Error creating the stack:\n #{e.response.body}"            
            end
            
            begin
              events=cf.describe_stack_events(stack_fullname).body
              sorted_events=events['StackEvents']
              sorted_events.reverse.each do |event|
                printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']
              end
            rescue  Excon::Errors::BadRequest => e
              puts "[#{stack.name}] - Error fetching stack events:\n #{e.response.body}"
            end  

          else
            puts "[#{stack.name}] - Already exists"

            events=cf.describe_stack_events(stack_fullname).body
            sorted_events=events['StackEvents']
            sorted_events.reverse.each do |event|
              printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']
            end
          end

        end

      end


      on_selected_machines(selection) do |id,vm|

        # We need to get the correct provider  + region

        provider=@session.config.providers[vm.provider+"-"+vm.provider_options[:region]]
        if (id.nil?)
          create_options=vm.create_options
          boxname=vm.name
          puts "[#{boxname}] - Spinning up a new machine"

          create_options=create_options.merge({ :private_key_path => vm.private_key , :public_key_path => vm.public_key, :username => vm.user})

          #instance=provider.servers.bootstrap(create_options)

          instance=provider.servers.create(create_options)

          puts "[#{boxname}] - Waiting for the machine to become accessible"
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
          puts "[#{boxname}] - Waiting for ssh to become available"
          #puts instance.console_output.body["output"]

          Mccloud::Util.execute_when_tcp_available(instance.public_ip_address, { :port => 22, :timeout => 6000 }) do
            puts "[#{boxname}] - Ssh is available , proceeding with bootstrap"
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

        unless options["noprovision"]
          puts "Waiting for ssh to become available"
          Mccloud::Util.execute_when_tcp_available(vm.instance.public_ip_address, { :port => 22, :timeout => 6000 }) do
            puts "[#{boxname}] - Ssh is available , proceeding with bootstrap"
          end

          puts "[#{boxname}] - provision step #{vm.name}"
          @session.provision(vm.name,options) 
        end
      end

    end





  end
end
