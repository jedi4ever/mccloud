require 'json'
require 'logger'


require 'fog'
require 'highline'
require 'highline/import'

require 'mccloud/config'

require 'mccloud/command/status'
require 'mccloud/command/up'
require 'mccloud/command/halt'
require 'mccloud/command/ssh'
require 'mccloud/command/boot'
require 'mccloud/command/bootstrap'
require 'mccloud/command/reload'
require 'mccloud/command/multi'
require 'mccloud/command/init'
require 'mccloud/command/suspend'
require 'mccloud/command/destroy'
require 'mccloud/command/provision'
require 'mccloud/command/server'
require 'mccloud/command/package'
require 'mccloud/command/deregister'

require 'mccloud/type/vm'
require 'mccloud/util/sshkey'



module Mccloud

  # We need some global thing for the config file to find our session
  def self.session=(value)
    @session=value
  end
  def self.session
    return @session
  end

  class Session
    attr_accessor :config
    attr_accessor :logger
    attr_accessor :all_servers
    attr_accessor :all_stacks

    include Mccloud::Command

    def initialize(options=nil)
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO

      #http://www.ruby-doc.org/stdlib/libdoc/logger/rdoc/classes/Logger.html
      @logger.datetime_format = "%Y-%m-%d %H:%M:%S"

      #logger.formatter = proc { |severity, datetime, progname, msg|
      #   "#{datetime} - #{severity}: #{msg}\n"
      # }
      @session=self
      Mccloud.session=self
    end

    def load_config(options=nil)
      @logger.debug "Loading mccloud config"
      #if File.exist?(path)
      begin
        Kernel.load File.join(Dir.pwd,"Mccloudfile")
      rescue LoadError => e
        @logger.error "Error loading configfile - Sorry"
        @logger.error e.message  
        @logger.error e.backtrace.inspect  
        exit -1
      end



      #Loading providers for Stacks
      Mccloud.session.config.stacks.each do |name,stack|
        if @session.config.providers[stack.provider+"-"+stack.provider_options[:region].to_s].nil?
          puts "adding provider #{stack.provider}-#{stack.provider_options[:region].to_s}"

          provider_options={:provider => stack.provider}
          provider_options.merge!(stack.provider_options)
          @logger.debug "adding provider #{stack.provider}"
          begin
            @session.config.providers["#{stack.provider+"-"+stack.provider_options[:region].to_s}"]=Fog::Compute.new(provider_options)
          end
        end
      end


      #Loading providers for VMS
      Mccloud.session.config.vms.each do |name,vm|
        if @session.config.providers[vm.provider+"-"+vm.provider_options[:region].to_s].nil?
          puts "adding provider #{vm.provider}-#{vm.provider_options[:region].to_s}"

          provider_options={:provider => vm.provider}
          provider_options.merge!(vm.provider_options)
          @logger.debug "adding provider #{vm.provider}"
          begin
            @session.config.providers["#{vm.provider+"-"+vm.provider_options[:region].to_s}"]=Fog::Compute.new(provider_options)
          rescue ArgumentError => e
            #  Missing required arguments: 
            required_string=e.message
            required_string["Missing required arguments: "]=""
            required_options=required_string.split(", ")
            puts "Please provide credentials for provider [#{vm.provider}]:"
            answer=Hash.new
            for fog_option in required_options do 
              answer["#{fog_option}".to_sym]=ask("- #{fog_option}: ") 
              #{ |q| q.validate = /\A\d{5}(?:-?\d{4})?\Z/ }
            end
            puts "\nThe following snippet will be written to #{File.join(ENV['HOME'],".fog")}"

            snippet=":default:\n"
            for fog_option in required_options do
              snippet=snippet+"  :#{fog_option}: #{answer[fog_option.to_sym]}\n"
            end

            puts "======== snippit start ====="
            puts "#{snippet}"
            puts "======== snippit end ======="
            confirmed=agree("Do you wan to save this?: ")

            if (confirmed)
              fogfilename="#{File.join(ENV['HOME'],".fog")}"
              fogfile=File.new(fogfilename,"w")
              fogfile.puts "#{snippet}"
              fogfile.close
              FileUtils.chmod(0600,fogfilename)
            else
              puts "Ok, we won't write it, but we continue with your credentials in memory"
              exit -1
            end
            begin
              answer[:provider]= vm.provider
              @session.config.providers[vm.provider]=Fog::Compute.new(answer)
            rescue
              puts "We tried to create the provider but failed again, sorry we give up"
              exit -1
            end
          end 

        end
      end


      #provider_keypair=@provider.key_pairs.create(
      #  :name => keyName,
      # :public_key => rsa_key.ssh_public_key )
      #  puts "Registered #{keyName} with your cloud provider"



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



      #listing stacks
      @session.config.stacks.each do |name,stack|
        stack.filtered_instance_names.each do |instancename|
          puts "Stack #{name} - #{instancename}"

        end
      end

      # Loading defined VMS 
#      @session.config.vms.each do |name,vm|
#        
#      end
      
      #Resetting the list
      filter=@session.config.mccloud.filter
      stack_filter=@session.config.mccloud.stackfilter

      # For all providers
      @session.config.providers.each do |name,provider|
        server_list=Hash.new

        # get all servers running on each provider (filtered)
        provider.servers.each do |server|

          unless server.state=="terminated"

            full_name="#{server.tags['Name']}"
            if full_name.start_with?(filter)

              temp_name=String.new(full_name)
              temp_name[filter]=""
              short_name=temp_name

              #  if the VM was not declared
              unless !@session.config.vms[short_name].nil?
                puts "#{short_name} - has been not been declared as a vm"
                undeclared_vm=Mccloud::Type::Vm.new	
                undeclared_vm.declared=false
                undeclared_vm.server_id=server.id
                @session.config.vms[short_name]=undeclared_vm                
              else

              end

  
              # Set the server.id of the vm
              @session.config.vms[short_name].server_id=server.id
              @session.config.vms[short_name].provider=name

              # Check if the server is part of a stack
              stack_name=server.tags['aws:cloudformation:stack-name']

              unless stack_name.nil?
                filtered_stack_name=stack_name
                filtered_stack_name[stack_filter]=""
                # Lookup stack on our config
                puts "#{short_name} is part of #{filtered_stack_name} "

                if @session.config.stacks.has_key?(filtered_stack_name)
                  # If we found it, set the private, public and user appropriatly
                  puts "We're in luck"
                  @session.config.vms[short_name].private_key=@session.config.stacks[filtered_stack_name].private_key_for_instance(short_name)
                  @session.config.vms[short_name].public_key=@session.config.stacks[filtered_stack_name].public_key_for_instance(short_name)
                  @session.config.vms[short_name].user=@session.config.stacks[filtered_stack_name].user_for_instance(short_name)

                else
                  puts "Stack #{filtered_stack_name} is not defined "

                end



              end


            end
          end
        end
      end

    end
  end
end
