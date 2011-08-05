require 'mccloud/provider/libvirt/command/status'

module Mccloud::Provider
  class Libvirt

    attr_accessor :provider_options
    attr_accessor :raw_provider
    attr_accessor :name
    attr_accessor :type
    attr_accessor :session

    include Mccloud::Provider::LIBVIRT::Command


    def initialize(provider_options)
      @provider_options=provider_options
      @type=self.class.to_s.split("::").last
      @name="#{@type}-#{@provider_options[:uri].to_s}"      
      @raw_provider_options={}
    end

    def load(session)
      @session=session

      gems=%w{ruby-libvirt fog}
      
      gems.each do |gemname|
        availability_gem=Gem.available?("#{gemname}")
        unless availability_gem
          @session.logger.error "The #{gemname} gem is not installed and is required by the LIBVIRT provider"
          exit
        end
     end
      

      if @session.config.providers[@name].nil?
        @session.logger.info "Loading provider #{@name}"
        @raw_provider_options={:provider => "LIBVIRT"}
        @raw_provider_options.merge!(@provider_options)
        @session.logger.debug "#{@type} options: #{@raw_provider_options}"

        begin
          @raw_provider=Fog::Compute.new(@raw_provider_options)
          @session.config.providers[@name]=self
        rescue ArgumentError => e
          handle_error(e)
        end
      else
        @session.logger.debug "#{@name} already loaded"        
      end     

    end



    include Mccloud::Util

    def up(selection,options)

      on_selected_machines(selection) do |id,vm|
        require 'mccloud/provider/libvirt/command/vm/up.rb'        
        vm=Mccloud::Provider::LIBVIRT::Command::Vm.new(vm,self)
        vm.up
      end

    end

    def ssh(selection,command,options)

      on_selected_machines(selection) do |id,vm|
        require 'mccloud/provider/libvirt/command/vm/ssh.rb'        
        vm=Mccloud::Provider::LIBVIRT::Command::Vm.new(vm,self)
        vm.ssh(command,options)
      end

    end
    
    def halt(selection,options)
      on_selected_machines(selection) do |id,vm|
        puts "Matched #{vm.name}"
        require 'mccloud/provider/libvirt/command/vm/halt.rb'
        
        vm=Mccloud::Provider::LIBVIRT::Command::Vm.new(vm,self)
        vm.halt
      end

    end

    def load_resources(filter)

      @session.config.vms.each do |name,vm|
        if vm.provider=="LIBVIRT"
          # Set the server.id of the vm
          puts "Loading resource #{name} - LIBVIRT"
          matched=@raw_provider.servers.all(:name => name)
          if matched.nil?
            @session.config.vms[name].server_id=nil
          else
            @session.config.vms[name].server_id=matched.first.name
          end
        end
      end
    end

    def handle_error(e)      
      puts e.to_s
    end

  end
end