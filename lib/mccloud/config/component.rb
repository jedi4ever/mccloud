module Mccloud
  class Config
    class Component

      attr_accessor :provider

      def initialize()
      end

      def method_missing(m, *args, &block)  
#         puts "There's no method called #{m} here -- please try again."  
       end
             
    end
  end
end #Module Mccloud
