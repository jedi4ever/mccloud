module Mccloud
  module Configurator
    class MccloudConfigurator
      attr_accessor :prefix
      attr_accessor :environment

      attr_accessor :identity
      attr_accessor :loglevel
      
      def initialize()
          @prefix="mccloud"
          @environment="development"
          @identity=""
          @loglevel=:info
      end   
      
      def filter()
        mcfilter=Array.new
        if !@prefix.nil? 
           mcfilter << @prefix 
        end
        if !@environment=="" 
           mcfilter << @environment 
           end
        if !@identity==""
           mcfilter << @identity 
        end
        return mcfilter.join(" - ")
      end  
       
    end
  end
end