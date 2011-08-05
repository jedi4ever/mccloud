      if Mccloud.session.config.mccloud.check_keypairs
      puts "Checking keypair(s)"
      #checking keypairs
      Mccloud.session.config.stacks.each do |name,stack|
        stack.key_name.each do |name,key_name|

          stack_provider=@session.config.providers["#{stack.provider+"-"+stack.provider_options[:region].to_s}"]
          pair=stack_provider.key_pairs.get("#{key_name}")
          if pair.nil?
            puts "#{key_name} does not exist at #{stack.provider} in region #{stack.provider_options[:region]}"
            puts "Key - #{key_name}"
            puts "File - #{stack.public_key[name]}"
            #reading private key
            public_key=""
            File.open("#{stack.public_key[name]}") {|f| public_key << f.read} 

            stack_provider.key_pairs.create(
            :name => key_name,
            :public_key => public_key )
          end
        end
      end

      
      @session.config.vms.each do |name,vm|
        vm_provider=@session.config.providers["#{vm.provider+"-"+vm.provider_options[:region].to_s}"]
        pair=vm_provider.key_pairs.get("#{vm.key_name}")
        if pair.nil?
          puts "Key - #{vm.key_name}"
          puts "#{key_name} does not exist at #{vm.provider} in region #{vm.provider_options[:region]}"
        end
      end
    end
      if Mccloud.session.config.mccloud.check_securitygroups
      puts "Checking security group(s)"
      @session.config.vms.each do |name,vm|
        vm_provider=@session.config.providers["#{vm.provider+"-"+vm.provider_options[:region].to_s}"]
      
        mcgroup=vm_provider.security_groups.get("#{vm.create_options[:groups].first}")
        if mcgroup.nil?
          "#{vm.create_options[:groups].first} does not exist at region #{vm.provider_options[:region].to_s}"
          sg=vm_provider.security_groups.new
          sg.name="#{vm.create_options[:groups].first}"
          sg.description="#{vm.create_options[:groups].first}"
          sg.save
          
          puts "Authorizing access to port 22"
          sg.authorize_port_range(22..22)
        end
      end      
     end