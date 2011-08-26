module Mccloud
  class Config
    class Mccloud
      
      attr_accessor :prefix
      attr_accessor :environment
      attr_accessor :identity
      
      attr_accessor :delimiter

      attr_accessor :loglevel
      

      def initialize()
          @prefix="mccloud"
          @delimiter="-"
          @environment=""
          @identity=""

          @loglevel=:info
      end   

#      def to_hash
#        result={}
#        [:prefix, :environment,:delimiter,:identity,:loglevel,:check_keypairs,:check_securitygroups].each do |param|
#          value=self.instance_variable_defined?("@#{param.to_s}") ? self.instance_variable_get("@#{param.to_s}") : nil
#          unless value.nil?
#            result[param]= value
#          end 
#        end
#        return result
#      end
      
    end #Class
    end #Module
end #Module
