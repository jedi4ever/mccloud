module Mccloud::Provider
  module Aws
    
  class Ip
    attr_accessor :provider
    attr_accessor :name

    attr_accessor :vmname
    attr_accessor :address
    
    def initialize
    end
    
    def instance
      if @this_instance.nil?
        full_provider="#{@provider}"
        # TODO hard coded
        begin
          @this_instance=Mccloud.session.config.providers["AWS-eu-west-1"].addresses.get(address)
          @this_instance
          if @this_instance.nil?
              puts "Sorry we can't find ip #{address} "
          end
        rescue Fog::Service::Error => e
          puts "Error: #{e.message}"
          exit
        end
       
        
        #puts full_provider
        #"#{@provider}"


        #TODO !!!! - hardcoded is here
        # @this_instance=Mccloud.session.config.providers["AWS-eu-west-1"].servers.get(server_id)

#        begin
#          if @provider=="AWS"
#            fullname= "#{Mccloud.session.config.mccloud.filter}#{name}"
#            @this_instance=Fog::AWS::ELB.new(provider_options).load_balancers.get(fullname)
#            if @this_instance.nil?
#              puts "Sorry we can't find ip with #{fullname} "
#            end
#          end
#        rescue Fog::Service::Error => e
#          puts "Error: #{e.message}"
#          puts "We could not request the information from your provider #{provider}. We suggest you check your credentials."
#          puts "Check configuration file: #{File.join(ENV['HOME'],".fog")}"
#          exit -1
#        end
#      end
      end
       return @this_instance
    end
    
  end #Class
end #module Type
end #Module Mccloud