require 'mccloud/type/forwarding'
module Mccloud
  module Type
    
  class Vm
    attr_accessor :ami
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :create_options
    attr_accessor :name
    attr_accessor :user
    attr_accessor :server_id
    attr_accessor :private_key
    attr_accessor :public_key
    attr_accessor :key_name

    attr_accessor :auto_selection
    
    attr_accessor :bootstrap
    attr_accessor :provisioner
    attr_accessor :forwardings
    attr_accessor :stacked
    attr_accessor :declared
    
    attr_accessor :instance
    
    def initialize
      @forwardings=Array.new
      @stacked=false
      @auto_selection=true
      @declared=true
      @provisioner=nil
      # Default to us-east-1
      @provider_options={:region => "us-east-1"}
    end
    
    def declared?
      return declared
    end
    
    def stacked?
      return stacked
    end
    
    def auto_selected?
      return auto_selection
    end
    
    def provision(type)
      case type
      when :chef_solo
        @provisioner=Mccloud::Provisioner::ChefSolo.new
      when :puppet
        @provisioner=Mccloud::Provisioner::Puppet.new        
      else
      end
      yield @provisioner
      
      #Mccloud.session.config.provisioners[type.to_s]=@provisioner
#      @vm.provisioner=@provisioner
    end
    
    def instance
    
      if @this_instance.nil?
        begin
         # puts "#{provider}"
         # puts " - #{provider_options[:region]} - testing"
         #pp Mccloud.session.config.providers
         #-#{provider_options[:region]}"
         full_provider="#{@provider}"
         #puts full_provider
         #"#{@provider}"


         #TODO !!!! - hardcoded is here
          @this_instance=Mccloud.session.config.providers["AWS-eu-west-1"].servers.get(server_id)
        rescue Fog::Service::Error => e
          puts "Error: #{e.message}"
          puts "We could not request the information from your provider #{provider}. We suggest you check your credentials."
          puts "Check configuration file: #{File.join(ENV['HOME'],".fog")}"
          exit -1
        end
      end
      return @this_instance
    end
    
    def reload
      @this_instance=nil
    end
    def forward_port(name,local,remote)
      forwarding=Forwarding.new(name,local,remote)
      forwardings << forwarding
    end
  end
  
end
end #Module Mccloud