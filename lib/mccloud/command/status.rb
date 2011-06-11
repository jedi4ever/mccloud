module Mccloud
  module Command
    def status(selection=nil,options=nil)

      unless options.verbose?

        filter=@session.config.mccloud.filter
        puts "Using Filter: #{filter}"

        puts
        puts "Server(s)"
          
        printf "%-10s %-12s %-20s %-15s %-8s\n", "Name", "Instance Id", "IP", "Type","Status"
        80.times { |i| printf "=" } ; puts
      else
        filter=""
      end

      regions=["us-east-1","eu-west-1"]
      
      regions.each do |region|
      cf = Fog::AWS::CloudFormation.new(:region => region)
      
      
      cf.describe_stacks.body["Stacks"].each do |stack|
        name="#{stack['StackName']}"
        stackfilter=filter.gsub(/-/,'')
        puts "#{stackfilter}"
        if name.start_with?(stackfilter)
          puts "#{stack['StackName']} - #{stack['StackStatus']}"
          events = cf.describe_stack_events("#{stack['StackName']}").body['StackEvents']
           events.each do |event|
             puts "-- Timestamp: #{event['Timestamp']}"
             puts "-- LogicalResourceId: #{event['LogicalResourceId']}"
             puts "-- ResourceType: #{event['ResourceType']}"
             puts "-- ResourceStatus: #{event['ResourceStatus']}"
             puts "-- ResourceStatusReason: #{event['ResourceStatusReason']}" if event['ResourceStatusReason']
             puts "--"
           end

          puts 
          puts "Outputs for stack : #{stack['StackName']}"
          stack['Outputs'].each do |output|
            puts "#{output['OutputKey']}: #{output['OutputValue']}"
          end
          puts

        end


      end
  
    end
           
        
      @session.config.providers.each  do |name,provider|
          
          provider.servers.each do |vm|
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
          
        end #providers

        puts
        puts "Images:"
        80.times { |i| printf "=" } ; puts
        # Loop over images
        @session.config.providers.each  do |name,provider|
          puts "#{name}"
          #pp provider
          images_list=provider.images.all({"Owner" => "self"}) 
          images_list.each do |image|
              printf "%-10s %-10s %-10s %-20s\n",image.id,image.name.gsub(/"#{filter}"/,''),image.state, image.description[0..20]
              #pp image
          end
          
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
          puts "[#{name}] #{ip.address} - #{ip.instance.server_id}"   
        end
        
    end #def
  end #module
end
