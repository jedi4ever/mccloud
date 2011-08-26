module Mccloud::Provider
  module Aws
    
  class Lb
    attr_accessor :provider

    attr_accessor :name
    
    attr_accessor :members
    attr_accessor :sorry_members
    
    def initialize
    end
    
    def instance
      if @this_instance.nil?
        begin
          if @provider=="AWS"
            fullname= "#{Mccloud.session.config.mccloud.filter}#{name}"
            @this_instance=Fog::AWS::ELB.new(provider_options).load_balancers.get(fullname)
            if @this_instance.nil?
              puts "Sorry we can't find Loadbalancer with #{fullname} "
            end
          end
        rescue Fog::Service::Error => e
          puts "Error: #{e.message}"
          puts "We could not request the information from your provider #{provider}. We suggest you check your credentials."
          puts "Check configuration file: #{File.join(ENV['HOME'],".fog")}"
          exit -1
        end
      end
      return @this_instance
    end
    
  end
  
end
end #Module Mccloud