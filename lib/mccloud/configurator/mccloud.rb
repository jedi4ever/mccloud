module Mccloud
  module Configurator
    class MccloudConfigurator
      attr_accessor :prefix
      attr_accessor :environment
      attr_accessor :delimiter

      attr_accessor :identity
      attr_accessor :loglevel
      attr_accessor :check_keypairs
      attr_accessor :check_securitygroups
      
      def initialize()
          @prefix="mccloud"
          @delimiter="-"
          @environment=""
          @identity=""
          @check_securitygroups=true
          @check_keypairs=true
          @loglevel=:info
      end   
      
      def stackfilter
        vmfilter=self.filter
        filter=vmfilter.gsub!(/[^[:alnum:]]/, '')
        return filter
      end
      def filter()
        mcfilter=Array.new
        if !@prefix.nil? 
           mcfilter << @prefix 
        end
        if @environment!="" 
           mcfilter << @environment
        end
        if @identity!=""
           mcfilter << @identity 
        end
        full_filter=mcfilter.join(@delimiter)
        if full_filter.length>0
          full_filter=full_filter+@delimiter
        end
        return full_filter 
      end  
       
    end
  end
end