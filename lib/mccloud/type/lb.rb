require 'mccloud/type/forwarding'
module Mccloud
  module Type
    
  class Lb
    attr_accessor :provider
    attr_accessor :provider_options
    attr_accessor :name
    
    attr_accessor :members
    
    attr_accessor :instance
    
    def initialize
    end
    
    def instance
      if @this_instance.nil?
        begin
          @this_instance=Mccloud.session.config.providers[provider].servers.get(Mccloud.session.all_servers[name.to_s])
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