module Mccloud::Provider
  module AWS
    module Command
  
    def status(selection=nil,options=nil)

      unless options.verbose?

        filter=@session.config.mccloud.filter
        puts "Using Filter: #{filter}"

      else
        filter=""
      end

      regions=["us-east-1","eu-west-1"]
      
      puts
      puts "Stack(s)"        
      
      regions.each do |region|
      cf = Fog::AWS::CloudFormation.new(:region => region)
         
      cf.describe_stacks.body["Stacks"].each do |stack|
        name="#{stack['StackName']}"
        stackfilter=filter.gsub(/-/,'')
        if name.start_with?(stackfilter)
          short_name=stack['StackName'].dup
          short_name[stackfilter]=""
          puts "[#{short_name}] - #{stack['StackStatus']}"
          
          printf "  %-25s %-30s %-30s %-20s %-15s\n", "Timestamp", "Resource Type", "LogicalResourceId", "ResourceStatus","ResourceStatusReaon"
          120.times { |i| printf "=" } ; puts
          
          events = cf.describe_stack_events("#{stack['StackName']}").body['StackEvents']
          sorted_events=events.reverse
          sorted_events.each do |event|
             printf "  %-25s %-30s %-30s %-20s %-15s\n", event['Timestamp'],event['ResourceType'],event['LogicalResourceId'], event['ResourceStatus'],event['ResourceStatusReason']

           end

          puts 
          puts "  Outputs:"
          stack['Outputs'].each do |output|
            puts "  - #{output['OutputKey']}: #{output['OutputValue']}"
          end
          puts

        end


      end
  
    end
           
        
        puts
        puts "Server(s)"
          
        printf "%-10s %-12s %-20s %-15s %-8s\n", "Name", "Instance Id", "IP", "Type","Status"
        80.times { |i| printf "=" } ; puts
        
        @raw_provider.servers.each do |vm|
            name="<no name set>"
            if !vm.tags["Name"].nil?
              name=vm.tags["Name"].strip
            end #end if

            if name.start_with?(filter)
              unless filter==""
                name[filter]=""
                printf "%-10s %-12s %-20s %-20s %-15s %-8s\n",name,vm.id, vm.public_ip_address, vm.private_ip_address,vm.flavor.name,vm.state
              else
                puts "Name: #{name}"
                puts "Instance Id: #{vm.id}"
                puts "Public Ip: #{vm.public_ip_address}"
                puts "Flavor: #{vm.flavor.name}"
                puts "State: #{vm.state}"
                80.times { |i| printf "=" } ; puts
              end
            end
          end #End 1 provider
          

        puts
        puts "Images:"
        80.times { |i| printf "=" } ; puts
        # Loop over images
          #pp provider
          images_list=@raw_provider.images.all({"Owner" => "self"}) 
          images_list.each do |image|
              printf "%-10s %-10s %-10s %-20s\n",image.id,image.name.gsub(/"#{filter}"/,''),image.state, image.description[0..20]
              #pp image
          end
          
        puts 
        puts "Loadbalancers:"
        80.times { |i| printf "=" } ; puts

        @session.config.lbs.each do |name,lb|
          puts "[#{name}] #{lb.instance.dns_name}" 
          puts "[#{name}] - In  service: #{lb.instance.instances_in_service}"
          puts "[#{name}] - Out service: #{lb.instance.instances_out_of_service}"
          
        end
        
        puts 
        puts "Ips:"
        80.times { |i| printf "=" } ; puts

        @session.config.ips.each do |name,ip|
          puts "This needs some work! "
#          puts "[#{name}] #{ip.address} - #{ip.instance.server_id}"   
        end
        
    end #def
  end #module
    end #module
      end #module